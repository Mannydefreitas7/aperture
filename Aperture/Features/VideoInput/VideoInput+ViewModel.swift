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
    @Observable public class ViewModel {
        // Session
        private var session: CaptureSession? = nil
        private var cancellables: Set<AnyCancellable> = []
        // Layer
        var previewLayer: AVCaptureVideoPreviewLayer? = nil
        //
        public var hasConnectionTimeout: Bool = false
        // Computed
        var currentSession: CaptureSession { session ?? .init() }
        var hasSession: Bool { session != nil }
        var isRunning: Bool { currentSession.current.isRunning }
        //
        public var isConnecting: Bool = false

        public var videoLayer: Layer = .video
        public var placeholderLayer: Layer = .placeholder
        public var deviceId: AVDevice.ID = .defaultVideoId
        public var showSettings: Bool = false
        public var selectedDevice: AVDevice = .defaultDevice(.video)
        public var selectedID: AVDevice.ID? = .defaultVideoId
        @ObservationIgnored
        @Preference(\.isMirrored) var isMirrored
        //

        func setSession(_ session: CaptureSession) {
            self.session = session
            setDevice()
        }


        func onDisappear() {
            Console.info("\(videoLayer.name) is hidden")
            videoLayer.visibility = .hidden
        }

        private func setDevice() {
            // Start the video input
            if let selectedID, let device = DeviceDiscovery.shared.getDevice(withUniqueID: selectedID) {
                // start session with device
                Console.info("User has a default stored video id \(selectedID), setting video to \(selectedDevice.name)")
                deviceId = selectedID
                selectedDevice = device
            }
        }
    }
}

