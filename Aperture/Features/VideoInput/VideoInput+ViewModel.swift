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

        private var cancellables: Set<AnyCancellable> = []
        private var session: CaptureSession? = nil

        var previewLayer: AVCaptureVideoPreviewLayer? = nil
        //
        var isConnecting: Bool = false
        var connected: Bool = false
        var videoLayer: Layer = .init(name: "Video")
        var hasConnectionTimeout: Bool = false
        // Computed
        var currentSession: CaptureSession { session ?? .init() }
        var hasSession: Bool { session != nil }
        var isRunning: Bool { currentSession.current.isRunning }
        //
        public var showSettings: Bool = false
        public var selectedDevice: AVDevice = .defaultDevice(.video)
        //
        @ObservationIgnored
        @Published public var availableDevices: [AVDevice] = []
        @ObservationIgnored
        @Published public var deviceId: AVDevice.ID = AVDevice.defaultDevice(.video).id
        @ObservationIgnored
        @Preference(\.selectedVideoID) var selectedVideoID: AVDevice.ID?
        @ObservationIgnored
        @Preference(\.isMirrored) var isMirrored: Bool?

        init() {

            var isConnected = Published(wrappedValue: connected)
            isConnected.projectedValue.receive(on: RunLoop.main)
                .print("\(String(describing: #fileID)).\(String(describing: #function))")
                //.ignoreOutput()
                .sink(receiveValue: { _ in })
                .store(in: &cancellables)


        }

        func setSession(_ session: CaptureSession) {
            self.session = session
        }

        func onAppear() {
            Console.info("\(String(describing: #fileID)).\(String(describing: #function)) - Appear")
            videoLayer.visibility = .visible
        }

        func onDisappear() {
            Console.info("\(String(describing: #fileID)).\(String(describing: #function)) - Disappear")
            connected = false
        }

        func start() {
            // Start the video input
            Console.info(" Start video input session")
            if let selectedVideoID, let device = DeviceDiscovery.shared.getDevice(withUniqueID: selectedVideoID) {
                // start session with device
                Console.info("User has a default stored video id, using that: \(selectedVideoID)")
                deviceId = selectedVideoID
                selectedDevice = device
            }
        }
    }
}

