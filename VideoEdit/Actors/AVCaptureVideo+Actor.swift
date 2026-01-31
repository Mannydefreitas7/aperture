//
//  AVCaptureVideo+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-29.
//
import AVFoundation

actor AVCaptureVideoService {

    static let shared = AVCaptureVideoService()

    // MARK: - outputs
    var cameraCapture = MovieCapture()
    // MARK: - device lookup service
    private let deviceLookup = DeviceLookup()
    // MARK: - application
    private let audioApplication = AVAudioApplication.shared
    // MARK: - error message
    var errorMessage: String?
    //
    private var videoDevices: [AVDeviceInfo] = []
    // MARK: - video input
    var videoInput: AVCaptureDeviceInput?
    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureVideoOutput))

    init() {
        Task { try? await configure() }
    }

    // MARK: - configures the service
    func configure() async throws {
        guard let cameraDevice = DeviceLookup.defaultCamera else {
            throw AVError(.deviceNotConnected)
        }
        logger.log("Default video device: \(cameraDevice.localizedName)")
        videoInput = try AVCaptureDeviceInput(device: cameraDevice)
    }
    // MARK: - video device input
    var input: AVCaptureDeviceInput {
        get throws {
            guard let videoInput else {
                errorMessage = AVError(.deviceNotConnected).localizedDescription
                throw AVError(.deviceNotConnected)
            }
            return videoInput
        }
    }

    // MARK: - get audio devices
    func mapDevices() async throws -> [AVDeviceInfo] {
        let devices = devices()
        let selected = try input.device.uniqueID
        // updates camera devices
        let _videoDevices = devices.map {
            AVDeviceInfo(
                id: $0.uniqueID,
                kind: .video,
                name: $0.localizedName,
                isOn: $0.uniqueID == selected,
                showSettings: false,
                device: $0
            )
        }
        return _videoDevices
    }


    private func devices() -> [AVCaptureDevice] {
        deviceLookup.cameras
    }
    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

}
