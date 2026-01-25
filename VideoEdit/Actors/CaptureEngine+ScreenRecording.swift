//
//  CaptureEngine+ScreenRecording.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/24/26.
//

#if os(macOS)
import AVFoundation
import ScreenCaptureKit
import CoreMedia

// MARK: - Screen Recording Types

struct ScreenRecordingSettings: Sendable {
    var outputURL: URL
    var videoCodec: AVVideoCodecType
    var audioBitRate: Int
    var videoBitRate: Int
    var includeSystemAudio: Bool
    var includeMicrophoneAudio: Bool
    
    init(
        outputURL: URL? = nil,
        videoCodec: AVVideoCodecType = .h264,
        audioBitRate: Int = 128_000,
        videoBitRate: Int = 10_000_000,
        includeSystemAudio: Bool = true,
        includeMicrophoneAudio: Bool = false
    ) {
        // Generate default output URL if not provided
        if let outputURL = outputURL {
            self.outputURL = outputURL
        } else {
            let moviesDirectory = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let filename = "ScreenRecording-\(dateFormatter.string(from: Date())).mov"
            self.outputURL = moviesDirectory.appendingPathComponent(filename)
        }
        
        self.videoCodec = videoCodec
        self.audioBitRate = audioBitRate
        self.videoBitRate = videoBitRate
        self.includeSystemAudio = includeSystemAudio
        self.includeMicrophoneAudio = includeMicrophoneAudio
    }
}

enum ScreenRecordingError: Error {
    case noOutputURL
    case writerSetupFailed
    case alreadyRecording
    case notRecording
    case writerNotReady
}

struct ScreenRecording: Sendable {
    let url: URL
    let duration: TimeInterval
    let startTime: Date
    let endTime: Date
}

// MARK: - CaptureEngine Extension

extension CaptureEngine {
    
    // MARK: - Screen Recording State
    
    private var recordingState: ScreenRecordingState {
        get { ScreenRecordingState.shared }
    }
    
    // MARK: - Recording Management
    
    /// Starts recording screen capture with the given configuration and settings
    func startScreenRecording(
        captureConfig: ScreenCaptureConfiguration,
        recordingSettings: ScreenRecordingSettings = ScreenRecordingSettings()
    ) async throws -> URL {
        guard !recordingState.isRecording else {
            throw ScreenRecordingError.alreadyRecording
        }
        
        // Set up asset writer
        try await setupScreenRecordingWriter(
            width: captureConfig.width,
            height: captureConfig.height,
            settings: recordingSettings
        )
        
        // Start screen capture if not already capturing
        if await !screenCaptureState.isCapturing {
            try await startScreenCapture(with: captureConfig)
        }
        
        // Start consuming samples and writing them
        startScreenRecordingTask(settings: recordingSettings)
        
        recordingState.isRecording = true
        recordingState.startTime = Date()
        recordingState.settings = recordingSettings
        
        return recordingSettings.outputURL
    }
    
    /// Stops the current screen recording and returns the recorded file
    func stopScreenRecording() async throws -> ScreenRecording {
        guard recordingState.isRecording else {
            throw ScreenRecordingError.notRecording
        }
        
        let endTime = Date()
        let startTime = recordingState.startTime ?? Date()
        
        // Cancel the recording task
        recordingState.recordingTask?.cancel()
        recordingState.recordingTask = nil
        
        // Finalize the asset writer
        let outputURL = try await finalizeScreenRecording()
        
        // Clean up state
        recordingState.isRecording = false
        recordingState.isPaused = false
        
        let duration = endTime.timeIntervalSince(startTime)
        
        return ScreenRecording(
            url: outputURL,
            duration: duration,
            startTime: startTime,
            endTime: endTime
        )
    }
    
    /// Pauses the current screen recording
    func pauseScreenRecording() {
        guard recordingState.isRecording else { return }
        recordingState.isPaused = true
    }
    
    /// Resumes a paused screen recording
    func resumeScreenRecording() {
        guard recordingState.isRecording else { return }
        recordingState.isPaused = false
    }
    
    /// Returns the current recording duration
    var screenRecordingDuration: TimeInterval {
        guard let startTime = recordingState.startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    /// Returns whether a screen recording is currently in progress
    var isScreenRecording: Bool {
        recordingState.isRecording
    }
    
    // MARK: - Private Implementation
    
    private func setupScreenRecordingWriter(
        width: Int,
        height: Int,
        settings: ScreenRecordingSettings
    ) async throws {
        let url = settings.outputURL
        
        // Remove existing file if present
        try? FileManager.default.removeItem(at: url)
        
        // Create asset writer
        guard let writer = try? AVAssetWriter(outputURL: url, fileType: .mov) else {
            throw ScreenRecordingError.writerSetupFailed
        }
        
        // Configure video input
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: settings.videoCodec,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: settings.videoBitRate,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.expectsMediaDataInRealTime = true
        
        guard writer.canAdd(videoInput) else {
            throw ScreenRecordingError.writerSetupFailed
        }
        writer.add(videoInput)
        
        // Configure audio input if needed
        var audioInput: AVAssetWriterInput?
        if settings.includeSystemAudio || settings.includeMicrophoneAudio {
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderBitRateKey: settings.audioBitRate
            ]
            
            let input = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            input.expectsMediaDataInRealTime = true
            
            if writer.canAdd(input) {
                writer.add(input)
                audioInput = input
            }
        }
        
        // Store writer and inputs
        recordingState.assetWriter = writer
        recordingState.videoInput = videoInput
        recordingState.audioInput = audioInput
    }
    
    private func startScreenRecordingTask(settings: ScreenRecordingSettings) {
        let task = Task {
            let sampleStream = makeScreenCaptureSampleBufferStream()
            
            for await sampleBuffer in sampleStream {
                // Check if paused or cancelled
                if Task.isCancelled { break }
                if recordingState.isPaused { continue }
                
                // Process the sample buffer
                await processSampleForRecording(sampleBuffer)
            }
        }
        
        recordingState.recordingTask = task
    }
    
    private func processSampleForRecording(_ sampleBuffer: CMSampleBuffer) async {
        guard let writer = recordingState.assetWriter else { return }
        
        // Determine sample type
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        let mediaType = CMFormatDescriptionGetMediaType(formatDescription)
        
        // Start writing session if needed
        if writer.status == .unknown {
            let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            writer.startWriting()
            writer.startSession(atSourceTime: startTime)
        }
        
        // Append to appropriate input
        switch mediaType {
        case kCMMediaType_Video:
            if let videoInput = recordingState.videoInput,
               videoInput.isReadyForMoreMediaData {
                videoInput.append(sampleBuffer)
            }
            
        case kCMMediaType_Audio:
            if let audioInput = recordingState.audioInput,
               audioInput.isReadyForMoreMediaData {
                audioInput.append(sampleBuffer)
            }
            
        default:
            break
        }
    }
    
    private func finalizeScreenRecording() async throws -> URL {
        guard let writer = recordingState.assetWriter else {
            throw ScreenRecordingError.writerNotReady
        }
        
        // Mark inputs as finished
        recordingState.videoInput?.markAsFinished()
        recordingState.audioInput?.markAsFinished()
        
        // Finish writing
        await writer.finishWriting()
        
        let outputURL = writer.outputURL
        
        // Clean up writer
        recordingState.assetWriter = nil
        recordingState.videoInput = nil
        recordingState.audioInput = nil
        
        return outputURL
    }
}

// MARK: - Screen Recording State (Isolated Storage)

final class ScreenRecordingState {
    static let shared = ScreenRecordingState()
    
    var isRecording = false
    var isPaused = false
    var startTime: Date?
    var settings: ScreenRecordingSettings?
    var assetWriter: AVAssetWriter?
    var videoInput: AVAssetWriterInput?
    var audioInput: AVAssetWriterInput?
    var recordingTask: Task<Void, Never>?
    
    private init() {}
}

#endif
