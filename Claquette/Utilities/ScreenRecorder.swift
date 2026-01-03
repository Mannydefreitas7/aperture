import Foundation
import ScreenCaptureKit
import AVFoundation
import CoreMedia
import Combine

@MainActor
class ScreenRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var availableDisplays: [SCDisplay] = []
    @Published var availableWindows: [SCWindow] = []
    @Published var selectedDisplay: SCDisplay?
    @Published var selectedWindow: SCWindow?
    @Published var captureMode: CaptureMode = .display
    @Published var errorMessage: String?
    @Published var hasPermission: Bool = false

    enum CaptureMode {
        case display
        case window
        case area
    }
    
    private var stream: SCStream?
    private var streamOutput: CaptureOutput?
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var startTime: Date?
    private var timer: Timer?
    private var outputURL: URL?
    
    // Recording settings
    var recordMicrophone = true
    var recordSystemAudio = false
    var showCursor = true
    var highlightClicks = true
    var quality: RecordingQuality = .high
    
    init() {
        Task {
            await refreshAvailableContent()
        }
    }

    func checkPermission() {
        // Quick check using CGWindowListCopyWindowInfo
        let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] ?? []

        // If we can see window names, we have permission
        let hasNames = windowList.contains { window in
            window[kCGWindowName as String] != nil
        }

        hasPermission = hasNames
    }

    func requestPermission() async {
        do {
            // This triggers the system permission dialog
            _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)

            await MainActor.run {
                checkPermission()
            }
        } catch {
            print("Permission error: \(error)")
        }
    }

    func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    func refreshAvailableContent() async {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            availableDisplays = content.displays
            availableWindows = content.windows.filter { $0.isOnScreen && $0.frame.width > 100 }
            
            if selectedDisplay == nil {
                selectedDisplay = availableDisplays.first
            }
        } catch {
            errorMessage = "Failed to get available content: \(error.localizedDescription)"
        }
    }
    
    func startRecording() async throws -> URL {
        guard !isRecording else { throw RecordingError.alreadyRecording }
        
        // Create output URL
        let documentsPath = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "Recording-\(dateFormatter.string(from: Date())).mov"
        outputURL = documentsPath.appendingPathComponent(filename)
        
        // Configure stream
        let filter: SCContentFilter
        let configuration = SCStreamConfiguration()
        
        switch captureMode {
        case .display:
            guard let display = selectedDisplay else { throw RecordingError.noDisplaySelected }
            filter = SCContentFilter(display: display, excludingWindows: [])
            configuration.width = Int(display.width) * Int(quality.scaleFactor)
            configuration.height = Int(display.height) * Int(quality.scaleFactor)
            
        case .window:
            guard let window = selectedWindow else { throw RecordingError.noWindowSelected }
            filter = SCContentFilter(desktopIndependentWindow: window)
            configuration.width = Int(window.frame.width) * Int(quality.scaleFactor)
            configuration.height = Int(window.frame.height) * Int(quality.scaleFactor)
            
        case .area:
            guard let display = selectedDisplay else { throw RecordingError.noDisplaySelected }
            filter = SCContentFilter(display: display, excludingWindows: [])
            configuration.width = Int(display.width) * Int(quality.scaleFactor)
            configuration.height = Int(display.height) * Int(quality.scaleFactor)
        }
        
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(quality.frameRate))
        configuration.showsCursor = showCursor
        configuration.capturesAudio = recordSystemAudio
        configuration.pixelFormat = kCVPixelFormatType_32BGRA
        
        // Create stream
        stream = SCStream(filter: filter, configuration: configuration, delegate: nil)
        
        // Setup asset writer
        try setupAssetWriter(width: configuration.width, height: configuration.height)
        
        // Create output handler
        streamOutput = CaptureOutput(recorder: self)
        try stream?.addStreamOutput(streamOutput!, type: .screen, sampleHandlerQueue: DispatchQueue(label: "com.claquette.screen"))
        
        if recordSystemAudio {
            try stream?.addStreamOutput(streamOutput!, type: .audio, sampleHandlerQueue: DispatchQueue(label: "com.claquette.audio"))
        }
        
        // Start capture
        try await stream?.startCapture()
        
        let capturedStartTime = Date()
        startTime = capturedStartTime
        isRecording = true
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let elapsed = Date().timeIntervalSince(capturedStartTime)
            Task { @MainActor in
                self.recordingDuration = elapsed
            }
        }
        
        return outputURL!
    }
    
    func stopRecording() async throws -> URL {
        guard isRecording else { throw RecordingError.notRecording }
        
        timer?.invalidate()
        timer = nil
        
        try await stream?.stopCapture()
        stream = nil
        
        // Finalize asset writer
        videoInput?.markAsFinished()
        audioInput?.markAsFinished()
        
        await withCheckedContinuation { continuation in
            assetWriter?.finishWriting {
                continuation.resume()
            }
        }
        
        isRecording = false
        recordingDuration = 0
        
        return outputURL!
    }
    
    func pauseRecording() {
        isPaused = true
    }
    
    func resumeRecording() {
        isPaused = false
    }
    
    private func setupAssetWriter(width: Int, height: Int) throws {
        guard let url = outputURL else { throw RecordingError.noOutputURL }
        
        // Remove existing file
        try? FileManager.default.removeItem(at: url)
        
        assetWriter = try AVAssetWriter(outputURL: url, fileType: .mov)
        
        // Video settings
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 10_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput?.expectsMediaDataInRealTime = true
        
        if assetWriter?.canAdd(videoInput!) == true {
            assetWriter?.add(videoInput!)
        }
        
        // Audio settings
        if recordSystemAudio || recordMicrophone {
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderBitRateKey: 128000
            ]
            
            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioInput?.expectsMediaDataInRealTime = true
            
            if assetWriter?.canAdd(audioInput!) == true {
                assetWriter?.add(audioInput!)
            }
        }
    }
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, type: SCStreamOutputType) {
        guard !isPaused else { return }
        
        switch type {
        case .screen:
            if assetWriter?.status == .unknown {
                assetWriter?.startWriting()
                assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            }
            
            if videoInput?.isReadyForMoreMediaData == true {
                videoInput?.append(sampleBuffer)
            }
            
        case .audio, .microphone:
            if audioInput?.isReadyForMoreMediaData == true {
                audioInput?.append(sampleBuffer)
            }

        @unknown default:
            break
        }
    }
}

class CaptureOutput: NSObject, SCStreamOutput {
    weak var recorder: ScreenRecorder?
    
    init(recorder: ScreenRecorder) {
        self.recorder = recorder
    }
    
    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        Task { @MainActor in
            recorder?.processSampleBuffer(sampleBuffer, type: type)
        }
    }
}
