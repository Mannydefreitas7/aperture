//
//  Device+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-17.
//

import Foundation
import AVFoundation

@globalActor
public actor DeviceManager {

    public static let shared = DeviceManager()

    var videoDevices: [AVCaptureDevice] = []
    var audioDevices: [AVCaptureDevice] = []
    var currentSession: AVCaptureSession = .init()
    var currentVideoInput: AVCaptureDeviceInput?
    var currentAudioInput: AVCaptureDeviceInput?

    // Get default system device.
    private let defaultVideoDevice = AVCaptureDevice.systemPreferredCamera
    private let defaultAudioDevice = AVCaptureDevice.default(for: .audio)

    // Computed properties
    var isSessionRunning: Bool { currentSession.isRunning }

    /// Fetch all devices.
    func fetchDevices() async throws {
        let _cameras = await self.availableCameras()
        let _microphones = await self.availableMicrophones()

        guard !_cameras.isEmpty, let preferred = _cameras.first(where: { $0.isConnected }) else {
            throw AVError.init(_nsError: .init(domain: String(describing: self), code: 0))
        }

    }

    /// Fetch all video devices available on the current computer.
    private func availableCameras() async -> [AVCaptureDevice]  {

        let fetch = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        return fetch.devices.filter { $0.isConnected }
    }

    /// Fetch all audio devices available on the current computer.
    private func availableMicrophones() async -> [AVCaptureDevice] {

        let fetch = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone, .external],
            mediaType: .audio,
            position: .unspecified
        )
        return fetch.devices.filter { $0.isConnected }
    }

    /// Sets the video or audio device input
    func setInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        let input = try AVCaptureDeviceInput(device: device)
        if device.hasMediaType(.video) {
            currentVideoInput = input
            return input
        }

        currentAudioInput = input
        return input
    }

    /// Checks and add input to session
    func addInputToSession(_ input: AVCaptureDeviceInput) throws {
        guard currentSession.canAddInput(input) else {
            throw NSError(domain: String(describing: self), code: AVError.sessionConfigurationChanged.rawValue)
        }
        currentSession.addInput(input)
    }

    ///
    func start(with devices: [AVCaptureDevice] = [], force: Bool = false) async throws {
        // Prevents from starting a new session if one is currently running.
        guard !currentSession.isRunning else {
            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
        }

        currentSession.beginConfiguration()
        currentSession.sessionPreset = .high

        // if force is not set, simply start the running session
        if !force {
            currentSession.commitConfiguration()
            currentSession.startRunning()
            return
        }


        // Check if devices are passed in.
        if !devices.isEmpty {
            for device in devices {
                let input = try setInput(for: device)
                // Check if session can add input.
                try addInputToSession(input)
            }
        }

        // Otherwise use system default.
        guard let defaultVideoDevice else {
            throw NSError(domain: String(describing: self), code: AVError.sessionConfigurationChanged.rawValue)
        }
       let input = try setInput(for: defaultVideoDevice)
        // Check if session can add input.
        try addInputToSession(input)

    }

    /// Remove existing session inputs
    func removeInputs() {
        guard currentSession.isRunning, !currentSession.inputs.isEmpty else { return }
        for input in currentSession.inputs {
            currentSession.removeInput(input)
        }
    }
}
