//
//  AVCaptureAudio+Actors.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-29.
//

import AVFoundation
import Accelerate
import AVFAudio

// Audio sample listener
actor AVAudioSampleListener {

    static let shared = AVAudioSampleListener()

    private let historyCapacity = 48
    private let smoothing = 0.75
    private let gain = max(0.1, 18)
    private var input: AVAudioInputNode?
    private let audioInstance = AVAudioApplication.shared
    private let audioEngine = AVAudioEngine()

    @Published var audioLevel: Float = 0
    @Published var peakLevel: Float = 0
    @Published var time: AVAudioTime = .init()
    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.audioLevel))
    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    var level: Float { audioLevel }
    //
    func start(_ inputNode: AVAudioInputNode) {
        let recordingFormat = inputNode.outputFormat(forBus: .zero)
        // Install a tap on the input node to get audio buffers
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            // Process the audio buffer here
            self.processAudioBuffer(buffer)
            self.time = when
        }
    }

    func setup(using connection: AVCaptureConnection?) throws {
        guard let connection, connection.isActive else { return }
        connection.audioChannels.forEach {
            logger.info("\($0.averagePowerLevel) \($0.peakHoldLevel) \($0.volume)")
            peakLevel = $0.averagePowerLevel
        }
    }

    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let channelDataArray = channelData[0]
        let frameLength = Int(buffer.frameLength)
        // Calculate the average power level (amplitude)
        var totalPower: Float = 0.0
        for i in 0..<frameLength {
            totalPower += abs(channelDataArray[i])
        }
        let averagePower = totalPower / Float(frameLength)
        audioLevel = averagePower * 10
        // You can define a threshold to "detect sound"
        if averagePower > 0.01 { // Example threshold
             // Sound is being detected
        }
    }
}

actor AVCaptureAudioService {

    static let shared = AVCaptureAudioService()
    // MARK: - outputs
    var audioFileCapture = AudioCapture()
    // MARK: - audio preview capture
    var audioPreviewCapture = AudioCapturePreview()
    // MARK: - device lookup service
    private let deviceLookup = DeviceLookup()
    // MARK: - application
    private let audioApplication = AVAudioApplication.shared
    // MARK: - audio device
    private var audioInput: AVCaptureDeviceInput?
    // MARK: - access authorization
    private var isAuthorized: Bool {
        let authorized = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        if !authorized {
            Task { return await AVCaptureDevice.requestAccess(for: .audio) }
        }
        return authorized
    }
    // MARK: - error message
    var errorMessage: String?

    // MARK: - capture audio service
    init() {
        Task { try? await configure() }
    }

    // MARK: - configures the service
    func configure() async throws {
        let audioDevice: AVDeviceInfo = .defaultDevice(.audio)
        guard isAuthorized, let device = audioDevice.device else { return }
        logger.log("Default audio device: \(audioDevice.name)")
        audioInput = try AVCaptureDeviceInput(device: device)
    }

    // MARK: - audio device input
    var input: AVCaptureDeviceInput {
        get throws {
            guard let audioInput else {
                errorMessage = AVError(.deviceNotConnected).localizedDescription
                throw AVError(.deviceNotConnected)
            }
            return audioInput
        }
    }

    // MARK: - get audio devices
    func mapDevices() async throws -> [AVDeviceInfo] {
        let devices = devices()
        let selectedDeviceID = try input.device.uniqueID

        // updates camera devices
        let _devices = devices.map {
            AVDeviceInfo(
                id: $0.uniqueID,
                kind: .video,
                name: $0.localizedName,
                isOn: $0.uniqueID == selectedDeviceID,
                showSettings: false,
                device: $0
            )
        }
        return _devices
    }

    // MARK: - get audio devices
    func devices() -> [AVCaptureDevice] {
        deviceLookup.microphones
    }
}
