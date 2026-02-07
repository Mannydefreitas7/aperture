//
//  VideoInput+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//
import SwiftUI
import AVFoundation
import Combine

extension VideoInputView {

    @MainActor
    @Observable
    final class ViewModel {

        private var captureSession: CaptureSession = .init()

        var sessionError: CaptureError? = nil
        var selectedDevice: AVDevice? = nil
        var isRecording: Bool = false

        var isRunning: Bool = false
        var url: URL? = nil

        var session: AVCaptureSession { captureSession.currentSession }

        var hasVideo: Bool {
            let connection = session.connections.first
            guard let connection, let selectedDevice, let device = selectedDevice.device else { return false }
            return device.isConnected && connection.isActive
        }

        func initialize() async {
            guard !captureSession.currentSession.isRunning else { return }
            await captureSession.initialize()
        }

        func start() async {
            do {
                if let selectedDevice {
                    try await captureSession.addDeviceInput(selectedDevice)
                    return
                }
                try await captureSession.addDeviceInput(.defaultDevice(.video))
            } catch {
                logger.error("Failed to add device input: \(error.localizedDescription)")
                sessionError = .noVideo
            }
        }

        func stop() async {
            await captureSession.stop()
        }
    }
}


