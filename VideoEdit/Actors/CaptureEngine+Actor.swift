//
//  CaptureEngine+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/18/26.
//
import AVFoundation

enum CaptureEngineError: Error {
    case noVideoDeviceAvailable
    case noAudioDeviceAvailable
}


actor CaptureEngine {

    // Exposed for preview layer wiring (reference type is OK to hand out).
    // Important: Mutate/configure ONLY via actor methods.
    nonisolated let session: AVCaptureSession = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: .dispatchQueueKey(.captureSession))

    // Inputs / outputs we manage
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?

    private let videoOutput = AVCaptureVideoDataOutput()
    private let audioOutput = AVCaptureAudioDataOutput()

    private var videoDiscovery: AVCaptureDevice.DiscoverySession?
    private var audioDiscovery: AVCaptureDevice.DiscoverySession?

    private var selectedVideoID: String?
    private var selectedAudioID: String?

    // Video frames stream
    private var videoStreamContinuation: AsyncStream<CMSampleBuffer>.Continuation?
    private var videoDelegate: VideoOutputDelegate?

    // Audio samples stream (optional, but included since you said “yes to all”)
    private var audioStreamContinuation: AsyncStream<CMSampleBuffer>.Continuation?
    private var audioDelegate: AudioOutputDelegate?

    // MARK: Public API

    func currentSelection() -> (videoID: String?, audioID: String?) {
        (selectedVideoID, selectedAudioID)
    }

    func setSelection(videoID: String?, audioID: String?) {
        self.selectedVideoID = videoID
        self.selectedAudioID = audioID
    }

    func refreshVideoDevices() -> [AVCaptureDevice] {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera
        ]
        let d = AVCaptureDevice.DiscoverySession(deviceTypes: types, mediaType: .video, position: .unspecified)
        self.videoDiscovery = d
        return d.devices
    }

    func refreshAudioDevices() -> [AVCaptureDevice] {
        // For audio inputs, DiscoverySession with mediaType .audio works well.
        // Note: some “audio devices” are better managed through AVAudioSession inputs.
        let d = AVCaptureDevice.DiscoverySession(deviceTypes: [.microphone], mediaType: .audio, position: .unspecified)
        self.audioDiscovery = d
        return d.devices
    }

    /// Request camera/mic permissions (call from UI on appear).
    func requestPermissions() async -> Bool {
        let cam = await AVCaptureDevice.requestAccess(for: .video)
        let mic = await AVCaptureDevice.requestAccess(for: .audio)
        return cam && mic
    }

    /// Configure session (inputs + outputs). Safe to call repeatedly; it rebuilds inputs.
    func configureSession(preferFrontCamera: Bool = false) async throws {
        try await runSessionConfig {
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }

            // Preset choice: pick something sane for both preview + video data output.
            // Adjust as needed (.high / .inputPriority / .hd1280x720 etc.)
            if self.session.canSetSessionPreset(.high) { self.session.sessionPreset = .high }

            // Ensure outputs exist once
            self.installOutputsIfNeeded()

            // Remove existing inputs
            if let vi = self.videoInput { self.session.removeInput(vi); self.videoInput = nil }
            if let ai = self.audioInput { self.session.removeInput(ai); self.audioInput = nil }

            // Determine selected devices (or fallback)
            let videoDevice = self.pickVideoDevice(preferFront: preferFrontCamera)
            let audioDevice = self.pickAudioDevice()

            // Add inputs
            if let videoDevice {
                let input = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoInput = input
                    self.selectedVideoID = videoDevice.uniqueID
                }
            }

            if let audioDevice {
                let input = try AVCaptureDeviceInput(device: audioDevice)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.audioInput = input
                    self.selectedAudioID = audioDevice.uniqueID
                }
            }
        }
    }

    func startRunning() async {
        await runOnSessionQueue {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stopRunning() async {
        await runOnSessionQueue {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    /// A stream of CMSampleBuffer frames from AVCaptureVideoDataOutput.
    /// Call once and keep it alive.
    func makeVideoSampleBufferStream() -> AsyncStream<CMSampleBuffer> {
        AsyncStream { continuation in
            // Store continuation on the actor
            Task { [weak self] in
                await self?.setVideoContinuation(continuation)
            }

            Task { [weak self] in
                await self?.installVideoDelegate()
            }

            continuation.onTermination = { [weak self] _ in
                Task { await self?.clearVideoStream() }
                Task { [weak self] in await self?.setVideoContinuation(nil) }
            }
        }
    }

    /// Optional: audio samples (if you need them).
    func makeAudioSampleBufferStream() -> AsyncStream<CMSampleBuffer> {
        AsyncStream { continuation in
            // Store continuation on the actor
            Task { [weak self] in
                await self?.setAudioContinuation(continuation)
            }

            Task { [weak self] in
                await self?.installAudioDelegate()
            }

            continuation.onTermination = { [weak self] _ in
                Task { await self?.clearAudioStream() }
                Task { [weak self] in await self?.setAudioContinuation(nil) }
            }
        }
    }

    // MARK: - Private

    private func installVideoDelegate() {
        // Create delegate that forwards frames by hopping back to the actor
        let delegate = VideoOutputDelegate { [weak self] sbuf in
            Task { await self?.yieldVideo(sbuf) }
        }
        // Store delegate and set on output while on the actor
        self.videoDelegate = delegate
        let outputQueue = DispatchQueue(label: .dispatchQueueKey(.captureVideoOutput))
        self.videoOutput.setSampleBufferDelegate(delegate, queue: outputQueue)
    }

    private func installAudioDelegate() {
        // Create delegate that forwards samples by hopping back to the actor
        let delegate = AudioOutputDelegate { [weak self] sbuf in
            Task { await self?.yieldAudio(sbuf) }
        }
        // Store delegate and set on output while on the actor
        self.audioDelegate = delegate
        let outputQueue = DispatchQueue(label: .dispatchQueueKey(.captureAudioOutput))
        self.audioOutput.setSampleBufferDelegate(delegate, queue: outputQueue)
    }

    // Hop-back helpers for nonisolated contexts (delegates/queues)
    private func setVideoContinuation(_ c: AsyncStream<CMSampleBuffer>.Continuation?) {
        self.videoStreamContinuation = c
    }

    private func setAudioContinuation(_ c: AsyncStream<CMSampleBuffer>.Continuation?) {
        self.audioStreamContinuation = c
    }

    private func yieldVideo(_ sbuf: CMSampleBuffer) {
        self.videoStreamContinuation?.yield(sbuf)
    }

    private func yieldAudio(_ sbuf: CMSampleBuffer) {
        self.audioStreamContinuation?.yield(sbuf)
    }

    private func installOutputsIfNeeded() {
        // Video output config
        videoOutput.alwaysDiscardsLateVideoFrames = true
        // Common pixel format for CVPixelBuffer usage
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]

        if !session.outputs.contains(where: { $0 === videoOutput }) {
            if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
        }

        // Audio output (only if you need raw audio samples)
        if !session.outputs.contains(where: { $0 === audioOutput }) {
            if session.canAddOutput(audioOutput) { session.addOutput(audioOutput) }
        }

        // Stabilize connections if present
        if let conn = videoOutput.connection(with: .video) {
            // You can set videoOrientation if you manage rotation elsewhere.
            conn.isVideoMirrored = false
        }
    }

    private func pickVideoDevice(preferFront: Bool) -> AVCaptureDevice? {
        let devices = videoDiscovery?.devices ?? refreshVideoDevices()

        // If user selected a specific device and it exists, use it.
        if let id = selectedVideoID, let d = devices.first(where: { $0.uniqueID == id }) {
            return d
        }

        // Otherwise choose a reasonable default.
        if preferFront, let front = devices.first(where: { $0.position == .front }) {
            return front
        }
        if let back = devices.first(where: { $0.position == .back }) {
            return back
        }
        return devices.first
    }

    private func pickAudioDevice() -> AVCaptureDevice? {
        let devices = audioDiscovery?.devices ?? refreshAudioDevices()
        if let id = selectedAudioID, let d = devices.first(where: { $0.uniqueID == id }) {
            return d
        }
        return devices.first
    }

    private func clearVideoStream() {
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
        videoDelegate = nil
        videoStreamContinuation = nil
    }

    private func clearAudioStream() {
        audioOutput.setSampleBufferDelegate(nil, queue: nil)
        audioDelegate = nil
        audioStreamContinuation = nil
    }

    private func runOnSessionQueue(_ work: @escaping () -> Void) async {
        await withCheckedContinuation { cont in
            sessionQueue.async {
                work()
                cont.resume()
            }
        }
    }

    private func runSessionConfig(_ work: @escaping () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { cont in
            sessionQueue.async {
                do { try work(); cont.resume() }
                catch { cont.resume(throwing: error) }
            }
        }
    }
}

