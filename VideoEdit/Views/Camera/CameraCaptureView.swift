//
//  VICameraCaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import AVFoundation
import AppKit
import Combine

struct CameraCaptureView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: CaptureView.ViewModel

//    @State private var viewModel: ViewModel = .init()
    @State private var spacing: CGFloat = 8
    @State private var isTimerEnabled: Bool = false
    @State private var timerSelection: TimeInterval.Option = .threeSeconds

    // User preferences to store/restore window parameters
    @Preference(\.aspectPreset) var aspectPreset
    @Preference(\.showSafeGuides) var showSafeGuides
    @Preference(\.showAspectMask) var showAspectMask
    @Preference(\.showPlatformSafe) var showPlatformSafe

//    @Namespace private var namespace
//    @Namespace private var namespace2

   // private let ratioSize = CGSize(width: 16, height: 9)

    var body: some View {

        NavigationStack  {
            ZStack(alignment: .bottom) {
                // MARK: Video preview
                VideoOutput()

                // MARK: Crop mask for selected ratio
                MaskAspectRatioView()

                // MARK: Bottom bar content
                BottomBar()
            }
            .environmentObject(appState)
        }
        // Keep the window resizable but constrained to 16:9.
        .windowAspectRatio(AspectPreset.youtube.ratio)
    }
}


extension CameraCaptureView {

    @ViewBuilder
    func VideoOutput() -> some View {
        VideoOutputView(captureSession: viewModel.session)
            .ignoresSafeArea(.all)
    }

    @ViewBuilder
    func BottomBar() -> some View {
        AudioInputProxy(viewModel: viewModel) {
            RecordingControlsView(viewModel: viewModel.controlsBarViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, .small)
        }

//            .inspector(isPresented: $viewModel.isSettingsPresented) {
//                EditorSettingsView()
//                    .background(Color(.underPageBackgroundColor))
//                    .inspectorColumnWidth(.columnWidth(spacing: .threeOfTwelve))
//            }
    }

    @ViewBuilder
    func MaskAspectRatioView() -> some View {
        MaskRatioOverlay(
            aspectPreset: aspectPreset,
            showGuides: showSafeGuides,
            showMask: showAspectMask,
            showPlatformSafe: showPlatformSafe
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    func timeLabel() -> some View {
        Text(viewModel.recordingTimeString)
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(viewModel.isRecording ? .red : .secondary)
    }

}


extension CameraCaptureView {

//    struct DesignToken {
//        static let defaultCornerRadius: CGFloat = 32
//        static let defaultBorderWidth: CGFloat = 1
//        static let defaultBorderColor: NSColor = .secondaryLabelColor
//        static let topPadding: CGFloat = 54
//        static let bottomPadding: CGFloat = 64
//        static let dimmingAlpha: CGFloat = 0.5
//
//        static let maskColor: Color = .recordingRed.opacity(0.1)
//        static let guideColor: Color = .white.opacity(0.5)
//    }
//
//    enum Mode: String, Hashable {
//        case screenshare
//        case camera
//    }

//    struct VideoOutputView: NSViewRepresentable {
//        typealias NSViewType = PlayerView
//        @Binding var captureSession: AVCaptureSession
//        @Binding var isMirror: Bool
//
//        func makeNSView(context: Context) -> PlayerView {
//            let player = PlayerView(captureSession: captureSession)
//            guard let previewLayer = player.previewLayer, let connection = previewLayer.connection, connection.isVideoMirroringSupported else {
//                return player
//            }
//            return player
//        }
//
//        func updateNSView(_ nsView: PlayerView, context: Context) {
//            guard let previewLayer = nsView.previewLayer, let connection = previewLayer.connection, connection.isVideoMirroringSupported else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                connection.automaticallyAdjustsVideoMirroring = false
//                connection.isVideoMirrored = isMirror
//            }
//        }
//    }
}



//actor Manager {
//
//    func availableCameras() -> [AVCaptureDevice] {
//        return AVCaptureDevice
//                .DiscoverySession(
//                    deviceTypes: [.builtInWideAngleCamera, .external],
//                    mediaType: .video,
//                    position: .unspecified
//                )
//                .devices
//    }
//
//
//
//    func start(_ session: AVCaptureSession, with selectedCamera: CameraInfo?) throws -> AVCaptureDeviceInput {
//        guard !session.isRunning else {
//            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
//        }
//
//        session.beginConfiguration()
//        session.sessionPreset = .high
//
//        // Remove existing inputs
//        for input in session.inputs {
//            session.removeInput(input)
//        }
//
//        // Add video input
//        guard let camera = selectedCamera, let input = try? AVCaptureDeviceInput(device: camera.device), session.canAddInput(input) else {
//            session.commitConfiguration()
//            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
//        }
//
//        return input
//    }
//
//    func stop(_ session: AVCaptureSession) async -> Void {
//        guard session.isRunning else { return }
//        session.stopRunning()
//    }
//
//    func addAudioInput(_ session: AVCaptureSession) -> AVCaptureSession {
//        guard let device = AVCaptureDevice.default(for: .audio) else { return session }
//        guard let input = try? AVCaptureDeviceInput(device: device) else { return session }
//        if session.canAddInput(input) {
//            session.addInput(input)
//        }
//        return session
//    }
//
//    func addVideoInput(_ session: AVCaptureSession, with selected: AVCaptureDevice? = nil) -> AVCaptureSession {
//        guard let defaultDevice = AVCaptureDevice.default(for: .video) else {  return session }
//        let device: AVCaptureDevice = selected ?? defaultDevice
//        guard let input = try? AVCaptureDeviceInput(device: device) else {  return session }
//        if session.canAddInput(input) {
//            session.addInput(input)
//        }
//        return session
//    }
//}


#Preview {
    @Previewable @StateObject var captureVM: CaptureView.ViewModel = .init()
    CameraCaptureView(viewModel: captureVM)
}
