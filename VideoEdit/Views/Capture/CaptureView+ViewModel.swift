//
//  CaptureView+.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//

import SwiftUI
import AVFoundation
import Combine
import CombineAsync

extension CaptureView {

    @MainActor
    final class ViewModel: ObservableObject {

        /// main capture session engine
        let engine: AVCaptureEngine = AVCaptureEngine.shared
        private var cancellables: Set<AnyCancellable> = []
        /// media actors
        private let audioService = AVCaptureAudioService.shared
        private let audioSampleBuffer = AVAudioSampleListener.shared
        private let videoService = AVCaptureVideoService.shared
        /// properties
        @Published var status: CaptureStatus = .idle
        @Published var videoDevices: [AVDeviceInfo] = []
        @Published var audioDevices: [AVDeviceInfo] = []
        @Published var isRecording: Bool = false
        @Published private(set) var recordingDuration: TimeInterval = 0
        /// Waveform / meters
        @Published var audioLevel: Float = 0
        @Published var audioHistory: [Double] = []
        @Published var selectedVideoDevice: AVDeviceInfo?
        @Published var selectedAudioDevice: AVDeviceInfo?
        /// View models
        @Published var controlsBarViewModel: RecordingControlsView.ViewModel =  .init()
        @Published var cameraOverlayViewModel: CameraOverlayView.ViewModel = .init()
        /// Recording time string
        var recordingTimeString: String {
            let total = Int(recordingDuration.rounded(.down))
            let h = total / 3600
            let m = (total % 3600) / 60
            let s = total % 60
            return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
        }

        func onAppear() async {
            status = .configuring
            do {
                /// Configure + start the single underlying captureSession.
                logger.debug("Starting capture engine")
                try await engine.start(with: .current)
                logger.info("Update and fetch available devices")
                try await updateEngineDevices()
                logger.info("Switch to default devices")
                await switchToDevice(.defaultMicrophone)
                await switchToDevice(.defaultCamera)
            } catch {
                status = .failed(message: String(describing: error))
                await onDisappear()
            }
        }

        func onDisappear() async {
//            observationTasks.forEach { $0.cancel() }
//            observationTasks.removeAll()
//            audioMonitorPollTask?.cancel()
//            audioMonitorPollTask = nil
            //   await audioMonitor.stop()
            status = .stopped
        }

        init() {
            /// Set engine session
            $selectedAudioDevice
                .compactMap { $0?.id }
                .combineLatest($audioDevices)
                .compactMap { (id, devices) in devices.first(where: { $0.id == id })  }
                .removeDuplicates()
                .map { audio in
                    let previous = self.controlsBarViewModel.microphone
                    return AVDeviceInfo(
                        id: audio.id,
                        kind: .audio,
                        name: audio.name,
                        isOn: previous.isOn,
                        showSettings: previous.showSettings,
                        device: audio.device
                    )
                }
                .assign(to: \.microphone, on: controlsBarViewModel)
                .store(in: &cancellables)

            $selectedVideoDevice
                .compactMap { $0?.id }
                .combineLatest($videoDevices)
                .compactMap { (id, devices) in devices.first(where: { $0.id == id })  }
                .removeDuplicates()
                .map { cam in
                    let previous = self.controlsBarViewModel.camera
                    return AVDeviceInfo(
                        id: cam.id,
                        kind: .video,
                        name: cam.name,
                        isOn: previous.isOn,
                        showSettings: previous.showSettings,
                        device: cam.device
                    )
                }
                .assign(to: \.camera, on: controlsBarViewModel)
                .store(in: &cancellables)

            $selectedAudioDevice
                .compactMap { $0 }
                .asyncSink { device in
                    if !device.isOn { return }
                    await self.switchToDevice(device)
                }
                .store(in: &cancellables)
        }

        /// Switch to a specific device
        func switchToDevice(_ device: AVDeviceInfo) async {
            let isVideo = device.kind == .video
            let currentDevice = isVideo ? selectedVideoDevice : selectedAudioDevice
            /// Current device
            guard let currentDevice else {
                logger.info("No input or device to switch to: \(device.name)")
                return
            }
            logger.info("No input or device to switch to: \(device.name)")
            do {
                try await engine.removeInput(for: currentDevice)
                try await engine.addInput(for: device)
            } catch {
                logger.error("Failed to remove input: \(error.localizedDescription)")
            }
        }

        // MARK: - Device Observation
        /// Observes the engine's published device lists and updates the ViewModel accordingly.
        private func updateEngineDevices() async throws {
            // updates camera devices
            videoDevices = try await videoService.mapDevices()
            // updates audio devices
            audioDevices = try await audioService.mapDevices()
        }
    }



    @MainActor
    final class ViewModell: ObservableObject {

        /// The engine
        let engine = CaptureEngine()
        //    private let audioMonitor = AVCaptureAudioMonitor()
        private var cancellables: Set<AnyCancellable> = []

        /// Published UI state
        @Published var status: CaptureStatus = .idle
        @Published var videoDevices: [AVDeviceInfo] = []
        @Published var audioDevices: [AVDeviceInfo] = []
        @Published var selectedVideoID: String?
        @Published var selectedAudioID: String?
        @Published var session: AVCaptureSession = .init()
        @Published var showRecordingButton: Bool = true
        @Published var isRecording: Bool = false
        @Published private(set) var recordingDuration: TimeInterval = 0

        /// Waveform / meters
        @Published var audioLevel: Float = 0
        @Published var audioHistory: [Double] = []
        @Published var selectedVideoDevice: AVDeviceInfo?
        @Published var selectedAudioDevice: AVDeviceInfo?
        @Published var controlsBarViewModel: RecordingControlsView.ViewModel = .init()
        @Published var cameraOverlayViewModel: CameraOverlayView.ViewModel = .init()

        /// Recording time string
        var recordingTimeString: String {
            let total = Int(recordingDuration.rounded(.down))
            let h = total / 3600
            let m = (total % 3600) / 60
            let s = total % 60
            return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
        }

        init() {
            /// Set engine session
            $selectedAudioID
                .combineLatest($audioDevices)
                .compactMap { (id, devices) in devices.first(where: { $0.id == id })  }
                .map { audio in
                    let previous = self.controlsBarViewModel.microphone

                    return AVDeviceInfo(
                        id: audio.id,
                        kind: .audio,
                        name: audio.name,
                        isOn: previous.isOn,
                        showSettings: previous.showSettings,
                        device: audio.device
                    )
                }
                .assign(to: \.microphone, on: controlsBarViewModel)
                .store(in: &cancellables)

            $selectedVideoID
                .combineLatest($videoDevices)
                .compactMap { (id, devices) in devices.first(where: { $0.id == id })  }
                .map { cam in
                    let previous = self.controlsBarViewModel.camera

                    return AVDeviceInfo(
                        id: cam.id,
                        kind: .video,
                        name: cam.name,
                        isOn: previous.isOn,
                        showSettings: previous.showSettings,
                        device: cam.device
                    )
                }
                .assign(to: \.camera, on: controlsBarViewModel)
                .store(in: &cancellables)
        }

        /// Modern observation tasks (async sequences)
        private var observationTasks: [Task<Void, Never>] = []
        private var audioMonitorPollTask: Task<Void, Never>?

        func onAppear() async {
            installObservers(for: engine.captureSession)
            status = .configuring

            do {
                await configureAudioSessionForCapture()
                /// Configure + start the single underlying captureSession.
                try await engine.start(with: .current)
                session = engine.captureSession
                let connections = session.connections
                let channels = connections.first { $0.isActive && !$0.audioChannels.isEmpty }.map { $0.audioChannels } ?? []
                if channels.isEmpty {
                    logger.debug("No audio channels found on first video track")
                }
                if let channel = channels.first {
                    logger.debug("Found audio channel: \(channel)")
                    connections.first?.output?.connection(with: .audio)
                }
                logger.debug("channels: \(channels)")
                status = .running
               // await updateEngineDevices()

                startAudioMonitorPolling()
            } catch {
                status = .failed(message: String(describing: error))
                await onDisappear()
            }
        }

        func onDisappear() async {
            observationTasks.forEach { $0.cancel() }
            observationTasks.removeAll()
            audioMonitorPollTask?.cancel()
            audioMonitorPollTask = nil
         //   await audioMonitor.stop()
            status = .stopped
        }
        
        private func startAudioMonitorPolling() {

            audioMonitorPollTask?.cancel()
            audioMonitorPollTask = nil
            audioMonitorPollTask = Task { @MainActor [weak self] in
                guard let self else { return }
                while !Task.isCancelled {
                    let snapshot = await self.engine.audioLevelMonitor.snapshot()
                    audioLevel = snapshot
                  //  self.audioHistory = snapshot.history
                    try? await Task.sleep(nanoseconds: 33_000_000) // ~30fps
                }
            }
        }

        func selectVideo(device: AVDeviceInfo) async {
            selectedVideoID = device.id

            await engine.change(device)
            startAudioMonitorPolling()
            // Device switching is handled inside the updated CaptureEngine implementation.
            // If you add an explicit device-switch API later, call it here.
        }

        func selectAudio(device: AVDeviceInfo) async {
            selectedAudioID = device.id
            await engine.change(device)
            startAudioMonitorPolling()
            // Device switching is handled inside the updated CaptureEngine implementation.
            // If you add an explicit device-switch API later, call it here.
        }

        func start() async {
            do {
                try await engine.start(with: .current)
                session = engine.captureSession
                status = .running
            } catch {
                status = .failed(message: String(describing: error))
            }
        }

        func stop() async {
            await engine.stop()
            status = .stopped
        }

        // MARK: - Internals
        private func installObservers(for session: AVCaptureSession) {
            let nc = NotificationCenter.default

            // Capture session interruptions
            observationTasks.append(
                Task { @MainActor in
                    for await notification in nc.notifications(named: AVCaptureSession.wasInterruptedNotification) {
                        logger.debug("Connection was interrupted, \(notification.name.rawValue)")
                        status = .interrupted(reason: .mediaDiscontinuity)
                    }
                })

            observationTasks.append(Task { @MainActor in
                for await notification in nc.notifications(named: AVCaptureSession.interruptionEndedNotification) {
                    logger.debug("Interruption ended, \(notification.name.rawValue)")
                    await start()
                }
            })

            // Runtime errors (optionally recover from mediaServicesWereReset)
            observationTasks.append(Task { @MainActor in
                for await note in nc.notifications(named: AVCaptureSession.runtimeErrorNotification) {
                    let err = note.userInfo?[AVCaptureSessionErrorKey] as? NSError
                    logger.debug("Run-time error, \(note.name.rawValue)")
                    status = .failed(message: err?.localizedDescription ?? "AVCaptureSession runtime error")

                    if let avErr = err as? AVError, avErr.code == .mediaDiscontinuity {
                        logger.debug("Code error is .mediaDiscontinuity, \(note.name.rawValue)")
                        await start()
                    }
                }
            })
        }

        private func configureAudioSessionForCapture() async {
            #if os(iOS)
            // Make this match your needs (bluetooth, speaker, etc.)
            // This runs on main actor; AVAudioSession expects main-thread friendliness.
            let a = AVAudioSession.sharedInstance()
            do {
                try a.setCategory(.playAndRecord,
                                  mode: .videoRecording,
                                  options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
                try a.setActive(true, options: [])
            } catch {
                status = .failed(message: "AVAudioSession error: \(error)")
            }
            #else
            // AVAudioSession is unavailable on macOS; nothing to configure here.
            #endif
        }
        

    }
}
