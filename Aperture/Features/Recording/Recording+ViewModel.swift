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
        // Some properties
        var isRecording: Bool = false
        var isTimerEnabled: Bool = false
        var timerSelection: TimeInterval.Option = .threeSeconds
        var isSettingsPresented: Bool = false
        var showRecordButton: Bool = true
        private(set) var recordingDuration: TimeInterval = 0
        /// Waveform / meters
        var audioLevel: Float = 0
        var audioHistory: [Double] = []
        var downsampledMagnitudes: [Float] = []
        var fftMagnitudes: [Float] = []
        var spacing: CGFloat { isTimerEnabled || isRecording ? .small : .zero }
        var toggleAnimation: Bool { isRecording || isTimerEnabled }

        @ObservationIgnored
        @Published var videoInput: VideoInputView.ViewModel = .init()
        @ObservationIgnored
        @Published var audioInput: AudioInputView.ViewModel = .init()
        @ObservationIgnored
        @Published var showSettings: AVMediaType? = nil
        //
        @ObservationIgnored
        @Preference(\.selectedAudioID) var selectedAudioID: AVDevice.ID?

        init() {



//            $microphone
//                .drop(while: { $0.showSettings.isFalsy })
//                .map { $0.showSettings.inverted }
//                .receive(on: RunLoop.main)
//                .sink { self.camera.showSettings = $0 }
//                .store(in: &cancellables)

//            $camera
//                .drop(while: { $0.showSettings.isFalsy })
//                .map { $0.showSettings.inverted }
//                .receive(on: RunLoop.main)
//                .sink { self.microphone.showSettings = $0 }
//                .store(in: &cancellables)

//            Publishers.CombineLatest($microphone, $camera)
//                .map { (microphone, camera) in
//                    let settingsVisible = microphone.showSettings || camera.showSettings
//                    if microphone.isOn { return !settingsVisible }
//                    if camera.isOn { return !settingsVisible }
//                    return false
//                }
//                .receive(on: RunLoop.main)
//                .assign(to: \.showRecordButton, on: self)
//                .store(in: &cancellables)
        }


        func prepare() async {
            // Initialization
            Console.info("initializing preview session")
            await previewSession.initialize()
            // Connecting the video input
            if !videoInput.hasSession {
                Console.info("connecting video input")
                videoInput.setSession(previewSession.currentSession)

                //
                $videoInput
                    .receive(on: RunLoop.main)
                    .print("\(String(describing: #function))")
                    .drop(while: { $0.selectedDevice.isOn && $0.connected })
                    .sink(receiveValue: { $0.start() })
                    .store(in: &cancellables)

                Publishers.CombineLatest($videoInput, $audioInput)
                    .receive(on: RunLoop.main)
                    .map(\.0.selectedDevice, \.1.selectedDevice)
                    .map { devices in devices.0.isOn || devices.1.isOn }
                    .assign(to: \.showRecordButton, on: self)
                    .store(in: &cancellables)
            }
        }

        func start() async {
            Console.info("\(String(describing: self)).\(String(describing: #function)) - starting preview session")
            Task(priority: .background) {
                _ = await previewSession.start(with: videoInput.selectedDevice, audioInput.selectedDevice)
            }
        }

        func destroy() async {
            // Destroying the view
            Console.info("\(String(describing: self)).\(String(describing: #function)) - deinitializing preview session")
            await previewSession.stop()
        }

        func onDeviceChange(previousId: AVDevice.ID, newId: AVDevice.ID?) {
            Task {
                Console.info("\(String(describing: #fileID)).\(String(describing: #function)) - previousId: \(previousId), newId: \(String(describing: newId))")
                await previewSession.onChangeDevice(previousId: previousId, newId: newId)
            }
        }
    }
}
