//
//  Recording+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//
import Combine
import SwiftUI
import AVFoundation

extension RecordingToolbar {

    @MainActor
    final class ViewModel : ObservableObject {

        private var cancellables: Set<AnyCancellable> = []
        private var previewSession: SessionStore = .init()
        private(set) var recordingDuration: TimeInterval = 0
        // Some properties
        var isRecording: Bool = false
        var isTimerEnabled: Bool = false
        var timerSelection: TimeInterval.Option = .threeSeconds
        @Published var showRecordButton: Bool = false
        /// Waveform / meters
        var audioLevel: Float = 0
        var audioHistory: [Double] = []
        var downsampledMagnitudes: [Float] = []
        var fftMagnitudes: [Float] = []
        var spacing: CGFloat { isTimerEnabled || isRecording ? .small : .zero }
        var toggleAnimation: Bool { isRecording || isTimerEnabled }
        // Inputs
        @Published var videoInput: VideoInputView.ViewModel = .init()
        @Published var audioInput: AudioInputView.ViewModel = .init()
        @Published var showingSettings: AVMediaType? = nil
        @Published var sessionStarted: Bool = false
        // Selected audio.
        @ObservationIgnored
        @Preference(\.selectedAudioID) var selectedAudioID: AVDevice.ID?
        // Computed properties
        var isAudioInputEnabled: Bool { audioInput.selectedDevice.isOn.isTruthy }
        var isVideoInputEnabled: Bool { videoInput.selectedDevice.isOn.isTruthy }
        var isSessionRunning: Bool { previewSession.currentSession.current.isRunning }

        init() {

            videoInput.$selectedDevice
                .receive(on: RunLoop.main)
                .merge(with: audioInput.$selectedDevice)
                .map(\.isOn, \.showSettings)
                .map { isOn, showSettings in isOn && !showSettings }
                .assign(to: \.showRecordButton, on: self)
                .store(in: &cancellables)


            $videoInput
                .map(\.showSettings)
                .map(\.isTruthy)
                .map { $0 ? AVMediaType.video : nil }
                .receive(on: RunLoop.main)
                .assign(to: \.showingSettings, on: self)
                .store(in: &cancellables)

            $audioInput
                .map(\.showSettings)
                .map(\.isTruthy)
                .map { $0 ? AVMediaType.audio : nil }
                .receive(on: RunLoop.main)
                .assign(to: \.showingSettings, on: self)
                .store(in: &cancellables)

            videoInput.$videoLayer
                .drop(while: { $0.visibility == .hidden })
                .map { $0.visibility == .visible }
                .receive(on: RunLoop.main)
                .asyncSink { layer in
                    Task { @MainActor in
                        if layer && self.sessionStarted == false {
                            await self.start()
                        }
                    }
                }
                .store(in: &cancellables)
        }


        func prepare() async {
            // Initialization
            do {
                try await previewSession.initialize("Preview")
                // Connecting the video input
                if !videoInput.hasSession {
                    Console.info("connecting preview video input")
                    videoInput.setSession(previewSession.currentSession)
                }
            } catch {
                Console.error("\(error.localizedDescription)")
            }
        }

        func start() async {
            guard sessionStarted == false else { return }
            Console.info("Starting preview session")
                do {
                    sessionStarted = try await previewSession.start(with: videoInput.selectedDevice)
                } catch {
                    Console.error("\(error.localizedDescription)")
                }
        }

        func turn(_ on: Bool) async {

        }

        func destroy() async {
            do {
                // Destroying the view
                Console.info("deinitializing preview session")
                try await previewSession.stop()
            } catch {
                Console.error(error.localizedDescription)
            }
        }

        func onDeviceChange(previousId: AVDevice.ID, newId: AVDevice.ID) {
            Task {
                do {
                    guard let device = DeviceDiscovery.shared.getDevice(withUniqueID: newId) else { return }
                    Console.info("Changing device - previousId: \(previousId), newId: \(String(describing: newId))")
                    try await previewSession.onChangeDevice(previousId: previousId, newDevice: device)
                } catch {
                    Console.error("\(error.localizedDescription)")
                }
            }
        }
    }
}
