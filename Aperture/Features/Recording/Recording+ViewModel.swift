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
    @Observable final class ViewModel {

        private var cancellables: Set<AnyCancellable> = []
        private var previewSession: SessionStore = .init()
        private(set) var recordingDuration: TimeInterval = 0
        // Some properties
        var isRecording: Bool = false
        var isTimerEnabled: Bool = false
        var timerSelection: TimeInterval.Option = .threeSeconds
        var showRecordButton: Bool  {
            if videoInput.selectedDevice.isOn {
                return videoInput.showSettings.isFalsy
            }
            if audioInput.selectedDevice.isOn {
                return audioInput.showSettings.isFalsy
            }
            return false
        }
        /// Waveform / meters
        var audioLevel: Float = 0
        var audioHistory: [Double] = []
        var downsampledMagnitudes: [Float] = []
        var fftMagnitudes: [Float] = []
        var spacing: CGFloat { isTimerEnabled || isRecording ? .small : .zero }
        var toggleAnimation: Bool { isRecording || isTimerEnabled }
        // Inputs
        var videoInput: VideoInputView.ViewModel = .init()
        var audioInput: AudioInputView.ViewModel = .init()

        var showingSettings: AVMediaType? = nil
        var sessionStarted: Bool = false
        // Selected audio.
        @ObservationIgnored
        @Preference(\.selectedAudioID) var selectedAudioID: AVDevice.ID?
        // Computed properties
       // var isAudioInputEnabled: Bool { audioInput.selectedDevice.isOn.isTruthy }
       // var isVideoInputEnabled: Bool { videoInput.selectedDevice.isOn.isTruthy }
        var isSessionRunning: Bool { previewSession.currentSession.current.isRunning }

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

        func start(_ visibility: Layer.Visibility)  {
            guard sessionStarted == false && visibility == .visible else { return }
            Console.info("Starting preview session")
            Task {
                do {
                    sessionStarted = try await previewSession.start(with: videoInput.selectedDevice)
                } catch {
                    Console.error("\(error.localizedDescription)")
                }
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
