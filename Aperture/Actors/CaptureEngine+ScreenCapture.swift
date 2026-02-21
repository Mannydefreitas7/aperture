//
//  CaptureEngine+ScreenCapture.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/24/26.
//

#if os(macOS)
@preconcurrency import AVFoundation
@preconcurrency import ScreenCaptureKit
import CoreMedia

// MARK: - Screen Capture Types

enum ScreenCaptureSource: Sendable {
    case display(SCDisplay)
    case window(SCWindow)
    case externalCamera(AVCaptureDevice)
}

struct ScreenCaptureConfiguration: Sendable {
    var source: ScreenCaptureSource
    var width: Int
    var height: Int
    var frameRate: Int
    var showsCursor: Bool
    var capturesAudio: Bool
    var scaleFactor: Double
    
    init(
        source: ScreenCaptureSource,
        width: Int? = nil,
        height: Int? = nil,
        frameRate: Int = 30,
        showsCursor: Bool = true,
        capturesAudio: Bool = false,
        scaleFactor: Double = 1.0
    ) {
        self.source = source
        self.frameRate = frameRate
        self.showsCursor = showsCursor
        self.capturesAudio = capturesAudio
        self.scaleFactor = scaleFactor
        
        // Set dimensions based on source if not provided
        switch source {
        case .display(let display):
            self.width = width ?? Int(display.width) * Int(scaleFactor)
            self.height = height ?? Int(display.height) * Int(scaleFactor)
        case .window(let window):
            self.width = width ?? Int(window.frame.width) * Int(scaleFactor)
            self.height = height ?? Int(window.frame.height) * Int(scaleFactor)
        case .externalCamera:
            self.width = width ?? 1920
            self.height = height ?? 1080
        }
    }
}

struct ScreenCaptureContent: Sendable {
    let displays: [SCDisplay]
    let windows: [SCWindow]
    let applications: [SCRunningApplication]
    
    var filteredWindows: [SCWindow] {
        windows.filter { $0.isOnScreen && $0.frame.width > 100 }
    }
}

enum ScreenCaptureError: Error {
    case permissionDenied
    case noDisplaySelected
    case noWindowSelected
    case streamConfigurationFailed
    case alreadyCapturing
    case notCapturing
}

// MARK: - CaptureEngine Extension

extension CaptureEngine {
    
    // MARK: - Screen Capture State
    internal var screenCaptureState: ScreenCaptureActor {
        get { ScreenCaptureActor.shared }
    }
    
    // MARK: - Permission Management
    
    /// Checks if the app has screen recording permission
    func checkScreenRecordingPermission() -> Bool {
        // Quick check using CGWindowListCopyWindowInfo
        let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]] ?? []
        
        // If we can see window names, we have permission
        let hasNames = windowList.contains { window in
            window[kCGWindowName as String] != nil
        }
        
        return hasNames
    }
    
    /// Requests screen recording permission from the user
    func requestScreenRecordingPermission() async throws -> Bool {
        do {
            // This triggers the system permission dialog
            _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            return checkScreenRecordingPermission()
        } catch {
            Console.error("Failed to request screen recording permission: \(error)")
            throw ScreenCaptureError.permissionDenied
        }
    }
    
    /// Opens System Preferences to the Screen Recording privacy settings
    func openScreenRecordingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // MARK: - Content Discovery
    
    /// Retrieves available displays, windows, and applications for screen capture
    func getAvailableScreenCaptureContent() async throws -> ScreenCaptureContent {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            return ScreenCaptureContent(
                displays: content.displays,
                windows: content.windows,
                applications: content.applications
            )
        } catch {
            Console.error("Failed to get available screen capture content: \(error)")
            throw ScreenCaptureError.permissionDenied
        }
    }
    
    /// Retrieves all available external cameras (non-built-in capture devices)
    func getAvailableExternalCameras() async -> [AVCaptureDevice] {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices
    }
    
    // MARK: - Screen Capture Session Management
    
    /// Starts capturing screen content (display or window) or external camera
    func startScreenCapture(with configuration: ScreenCaptureConfiguration) async throws {
        let isCapturing = await screenCaptureState.isCapturing
        guard !isCapturing else {
            throw ScreenCaptureError.alreadyCapturing
        }
        
        switch configuration.source {
        case .display, .window:
            try await startSCStreamCapture(with: configuration)
        case .externalCamera(let device):
            try await startExternalCameraCapture(device: device, configuration: configuration)
        }
        
        await screenCaptureState.setCapturing(true, configuration: configuration)
    }
    
    /// Stops the current screen capture session
    func stopScreenCapture() async throws {
        guard await screenCaptureState.isCapturing else {
            throw ScreenCaptureError.notCapturing
        }
        
        if let stream = await screenCaptureState.stream {
            try await stream.stopCapture()
            await screenCaptureState.clearStream()
        }
        
        await screenCaptureState.stopCapturing()
    }
    
    /// Creates an async stream of sample buffers from screen capture
    func makeScreenCaptureSampleBufferStream() -> AsyncStream<CMSampleBuffer> {
        AsyncStream { continuation in
            let captureState = ScreenCaptureActor.shared
            
            Task {
                await captureState.setScreenSampleContinuation(continuation)
            }
            
            continuation.onTermination = { _ in
                Task {
                    await captureState.clearScreenSampleStream()
                }
            }
        }
    }
    
    // MARK: - Private Implementation
    
    private func startSCStreamCapture(with configuration: ScreenCaptureConfiguration) async throws {
        // Create content filter
        let filter: SCContentFilter
        let streamConfig = SCStreamConfiguration()
        
        switch configuration.source {
        case .display(let display):
            filter = SCContentFilter(display: display, excludingWindows: [])
            
        case .window(let window):
            filter = SCContentFilter(desktopIndependentWindow: window)
            
        case .externalCamera:
            // This case is handled by startExternalCameraCapture
            return
        }
        
        // Configure stream settings
        streamConfig.width = configuration.width
        streamConfig.height = configuration.height
        streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(configuration.frameRate))
        streamConfig.showsCursor = configuration.showsCursor
        streamConfig.capturesAudio = configuration.capturesAudio
        streamConfig.pixelFormat = kCVPixelFormatType_32BGRA
        
        // Create and configure stream
        let stream = SCStream(filter: filter, configuration: streamConfig, delegate: nil)
        
        // Create output handler
        let output = ScreenCaptureOutput(engine: self)
        try stream.addStreamOutput(output, type: .screen, sampleHandlerQueue: .global(qos: .userInitiated))
        
        if configuration.capturesAudio {
            try stream.addStreamOutput(output, type: .audio, sampleHandlerQueue: .global(qos: .userInitiated))
        }
        
        // Start capture
        try await stream.startCapture()
        
        // Store state
        await screenCaptureState.setStream(stream, output: output)
    }
    
    private func startExternalCameraCapture(device: AVCaptureDevice, configuration: ScreenCaptureConfiguration) async throws {
        // For external cameras, we can integrate them into the existing AVCaptureSession
        // or create a separate session depending on requirements
        
        // Begin configuration
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // Remove existing video input if any
        if let currentInput = activeVideoInput {
            captureSession.removeInput(currentInput)
        }
        
        // Add the external camera input
        activeVideoInput = try addInput(for: device)
        
        // Configure controls for the new device
        configureControls(for: device)
        
        // Update capabilities
        updateCaptureCapabilities()
        
        // Start the session if not already running
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    // Internal method to yield screen capture samples
    func yieldScreenCaptureSample(_ sampleBuffer: CMSampleBuffer) async {
        await screenCaptureState.yieldSample(sampleBuffer)
    }
}

// MARK: - Screen Capture State (Isolated Storage)

actor ScreenCaptureActor {
    static let shared = ScreenCaptureActor()

    var isCapturing = false
    var stream: SCStream?
    var streamOutput: ScreenCaptureOutput?
    var currentConfiguration: ScreenCaptureConfiguration?
    var screenSampleContinuation: AsyncStream<CMSampleBuffer>.Continuation?
    
    private init() {}
    
    // Mutation methods
    func setCapturing(_ capturing: Bool, configuration: ScreenCaptureConfiguration?) {
        isCapturing = capturing
        currentConfiguration = configuration
    }
    
    func stopCapturing() {
        isCapturing = false
        currentConfiguration = nil
        streamOutput = nil
    }
    
    func setStream(_ stream: SCStream, output: ScreenCaptureOutput) {
        self.stream = stream
        self.streamOutput = output
    }
    
    func clearStream() {
        self.stream = nil
    }
    
    func setScreenSampleContinuation(_ continuation: AsyncStream<CMSampleBuffer>.Continuation) {
        self.screenSampleContinuation = continuation
    }
    
    func clearScreenSampleStream() {
        screenSampleContinuation = nil
    }
    
    func yieldSample(_ sampleBuffer: CMSampleBuffer) {
        screenSampleContinuation?.yield(sampleBuffer)
    }
}

// MARK: - Screen Capture Output Handler

final class ScreenCaptureOutput: NSObject, SCStreamOutput, @unchecked Sendable {
    private weak var engine: CaptureEngine?
    
    init(engine: CaptureEngine) {
        self.engine = engine
        super.init()
    }
    
    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard let engine = engine else { return }
        
        // Forward the sample buffer to the engine
        Task {
            await engine.yieldScreenCaptureSample(sampleBuffer)
        }
    }
}

#endif
