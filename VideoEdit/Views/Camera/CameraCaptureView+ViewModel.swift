//
//  CameraCaptureView+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//

import SwiftUI
import Combine
import AVFoundation

extension CameraCaptureView {
//
//    @Observable @MainActor
//    final class ViewModel {
//            private var manager: Manager = .init()
//            private var cancellables: Set<AnyCancellable> = []
//
//            @Published var session: AVCaptureSession = .init()
//            @Published var mode: Mode = .camera
//
//            @Published var videoDevices: [AVCaptureDevice] = []
//            @Published var selectedVideoDeviceID: String = ""
//            @Published var selectedResolution: ResolutionPreset = .p1080
//            @Published var includeAudio: Bool = true
//            @Published var isSettingsPresented: Bool = false
//
//            @Published var isRunning: Bool = false
//            @Published var isRecording: Bool = false
//
//            @Published var lastSavedURL: URL?
//            @Published var lastThumbnail: NSImage?
//            @Published var alert: UIAlerter?
//            @Published var colunmVisibility: NavigationSplitViewVisibility = .doubleColumn
//
//            @Published var playerControlViewModel: RecordingControlsView.ViewModel = .init()
//            @Published private(set) var recordingDuration: TimeInterval = 0
//
//            var recordingTimeString: String {
//                let total = Int(recordingDuration.rounded(.down))
//                let h = total / 3600
//                let m = (total % 3600) / 60
//                let s = total % 60
//                return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
//            }
//
//            // One serial queue for session ops + sample callbacks => no races.
//            private let captureQueue = DispatchQueue(label: "camera.capture.queue")
//
//            private var isConfigured = false
//            private var videoInput: AVCaptureDeviceInput?
//            private var audioInput: AVCaptureDeviceInput?
//
//            private let videoOutput = AVCaptureVideoDataOutput()
//            private let audioOutput = AVCaptureAudioDataOutput()
//
//            init() {
//                Task {
//                    await addInputs()
//                    // Load the available devices
//                    videoDevices = await manager.availableCameras()
//                }
//
//                if !session.isRunning {
//                    session.startRunning()
//                }
//            }
//
//            func addInputs() async {
//                _ = await manager.addAudioInput(session)
//                _ = await manager.addVideoInput(session)
//            }
//        }
}
