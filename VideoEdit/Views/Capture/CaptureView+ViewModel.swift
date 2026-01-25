//
//  CaptureView+.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//

import SwiftUI
import AVFoundation
import Combine

extension CaptureView {

    @MainActor
    final class ViewModel: ObservableObject {

        // The engine
        let engine = CaptureEngine()
        private let audioMonitor = AVCaptureAudioMonitor()

        private var cancellables: Set<AnyCancellable> = []

        // Published UI state
        @Published var status: CaptureStatus = .idle
        @Published var videoDevices: [DeviceInfo] = []
        @Published var audioDevices: [DeviceInfo] = []
        @Published var selectedVideoID: String?
        @Published var selectedAudioID: String?
        @Published var session: AVCaptureSession = .init()
        @Published var showRecordingButton: Bool = true
        @Published var isRecording: Bool = false
        @Published private(set) var recordingDuration: TimeInterval = 0

        // Waveform / meters
        @Published var audioLevel: Double = 0
        @Published var audioHistory: [Double] = []

        @Published var selectedVideoDevice: DeviceInfo?

        @Published var selectedAudioDevice: DeviceInfo?

        @Published var controlsBarViewModel: RecordingControlsView.ViewModel = .init()
        @Published var cameraOverlayViewModel: CameraOverlayView.ViewModel = .init()

        var recordingTimeString: String {
            let total = Int(recordingDuration.rounded(.down))
            let h = total / 3600
            let m = (total % 3600) / 60
            let s = total % 60
            return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
        }

        init() {
            // Set engine session
            session = engine.captureSession

            $audioLevel.receive(on: RunLoop.main)
                .sink { val in
                    logger.debug("Audio level: \(val)")
                }
                .store(in: &cancellables)
        }

        // Modern observation tasks (async sequences)
        private var observationTasks: [Task<Void, Never>] = []

        private var audioMonitorPollTask: Task<Void, Never>?

        func onAppear() async {
            installObservers(for: engine.captureSession)
            status = .configuring

            do {
                await configureAudioSessionForCapture()
                // Configure + start the single underlying captureSession.
                try await engine.start(with: .current)
                session = engine.captureSession
                status = .running

                // Start audio monitoring (reuses CaptureEngine audio stream).
                let stream = await engine.makeAudioSampleBufferStream()
                audioMonitorPollTask = await audioMonitor.start(using: stream)


                //
                let (level, history) = await audioMonitor.snapshot()
                logger.info("LEVEL: \(level) AND HISTORY: \(history)")
                audioLevel = level
                audioHistory = history

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
            status = .stopped
        }

        func selectVideo(id: String) async {
            selectedVideoID = id
            // Device switching is handled inside the updated CaptureEngine implementation.
            // If you add an explicit device-switch API later, call it here.
        }

        func selectAudio(id: String) async {
            selectedAudioID = id
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
                    for await _ in nc.notifications(named: AVCaptureSession.wasInterruptedNotification) {
                        status = .interrupted(reason: .mediaDiscontinuity)
                    }
                })

            observationTasks.append(Task { @MainActor in
                for await _ in nc.notifications(named: AVCaptureSession.interruptionEndedNotification) {
                    await start()
                }
            })

            // Runtime errors (optionally recover from mediaServicesWereReset)
            observationTasks.append(Task { @MainActor in
                for await note in nc.notifications(named: AVCaptureSession.runtimeErrorNotification) {
                    let err = note.userInfo?[AVCaptureSessionErrorKey] as? NSError
                    status = .failed(message: err?.localizedDescription ?? "AVCaptureSession runtime error")

                    if let avErr = err as? AVError, avErr.code == .mediaDiscontinuity {
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
            return
#endif
        }
    }


}
