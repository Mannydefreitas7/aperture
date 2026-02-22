//
//  Session+Store.swift
//  Aperture
//
//  Created by Emmanuel on 2026-02-17.
//

import Combine
import SwiftUI
import AVFoundation

@MainActor
@Observable class SessionStore {
    // Services
    private let deviceDescovery = DeviceDiscovery.shared
    // session
    private var session: CaptureSession = .init()
    private var cancellables: Set<AnyCancellable> = []
    private var sessionName: String = .unknown
    // View related
    var currentSession: CaptureSession { session }
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    var sessionError: SessionError? = nil
    var previewVideoID = AVDevice.defaultDevice(.video).id
    var previewAudioID = AVDevice.defaultDevice(.audio).id
    // Conditions
    var isConnecting: Bool = false
    var hasConnectionTimeout: Bool = false
    var showRecordButton: Bool = false
    // Initialize
    func initialize(_ name: String) async throws {
        guard !session.current.isRunning else {
            Console.info("Session (\(name)) is already running")
            throw SessionError.alreadyRunning(name: name)
        }
        sessionName = name
        await session.initialize()
    }

    // Start
    func start(with devices: AVDevice...) async throws -> Bool {
        guard session.current.isRunning else {
            throw SessionError.notRunning(name: sessionName)
        }
        for device in devices {
            try await session.addDeviceInput(device)
            Console.info("Adding device (\(device.kind.rawValue))\(device.name) to \(sessionName)")
        }
        return session.current.isRunning
    }

    func onChangeDevice(previousId: AVDevice.ID, newDevice: AVDevice) async throws {
        guard let newDevice = deviceDescovery.getDevice(withUniqueID: newDevice.id) else {
            throw SessionError.deviceNotFound(name: newDevice.name, session: sessionName)
        }
        // Ensure that the changed device is different
        // than the previous selected id.
        guard let previousDevice = deviceDescovery.getDevice(withUniqueID: previousId) else {
            try await session.addDeviceInput(newDevice)
            throw SessionError.deviceAlreadyAdded(name: newDevice.name, session: sessionName)
        }
        // Renmove the previous device input
        try await session.removeInput(for: previousDevice)
        Console.warning("Removed device: \(previousDevice.name)")
        // when previous input is successfully removed from session
        // add new device to running session
        try await session.addDeviceInput(newDevice)
        Console.info("Changed device to \(newDevice.name)")
    }

    func stop(input devices: AVDevice...) async throws {
        // Loop thru all devices passed down and remove input from session.
        for device in devices {
            try await session.removeInput(for: device)
            Console.info("Removing \(device.kind.rawValue)-\(device.name)")
        }
        await session.stop()
    }

    private func inputPort(for device: AVDevice, in session: AVCaptureSession) -> AVCaptureInput.Port? {
        guard let input = session.inputs
            .compactMap({ $0 as? AVCaptureDeviceInput })
            .first(where: { $0.device.uniqueID == device.id }) else {
            return nil
        }
        return input.ports.first(where: { $0.mediaType == .video })
    }
}
