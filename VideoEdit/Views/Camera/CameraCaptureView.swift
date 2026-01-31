//
//  VICameraCaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import AVFoundation
import AppKit
import AVKit
import Combine

struct CameraCaptureView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: CaptureView.ViewModel
    @State private var spacing: CGFloat = 8
    @State private var isTimerEnabled: Bool = false
    @State private var timerSelection: TimeInterval.Option = .threeSeconds

    // User preferences to store/restore window parameters
    @Preference(\.aspectPreset) var aspectPreset
    @Preference(\.showSafeGuides) var showSafeGuides
    @Preference(\.showAspectMask) var showAspectMask
    @Preference(\.showPlatformSafe) var showPlatformSafe

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

        //CustomCaptureView(session: viewModel.session)

        VideoOutputView(source: viewModel.engine.previewSource, captureSession: viewModel.engine.captureSession)
            .ignoresSafeArea(.all)
    }

    @ViewBuilder
    func BottomBar() -> some View {
       
            RecordingControlsView(viewModel: viewModel.controlsBarViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, .small)
                .environment(\.audioInputWave, viewModel.audioLevel)
                .environment(\.audioDevices, viewModel.audioDevices)
                .environment(\.videoDevices, viewModel.videoDevices)
                .environmentObject(appState.previewViewModel)
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

#Preview {
    @Previewable @StateObject var captureVM: CaptureView.ViewModel = .init()
    CameraCaptureView(viewModel: captureVM)
}

struct CustomCaptureView: NSViewRepresentable {

    var session: AVCaptureSession?

    init(session: AVCaptureSession? = nil) {
        self.session = session
    }

    func makeNSView(context: Context) -> AVCaptureView {
       let view = AVCaptureView()
        view.controlsStyle = .default
        view.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateNSView(_ nsView: AVCaptureView, context: Context) {
        nsView.setSession(session, showVideoPreview: true, showAudioPreview: true)
    }

    class Coordinator: NSObject, AVCaptureViewDelegate {
        func captureView(_ captureView: AVCaptureView, startRecordingTo fileOutput: AVCaptureFileOutput) {
            logger.info("\(captureView.fileOutput?.description ?? "")")
        }


    }
    func makeCoordinator() -> Coordinator { Coordinator() }
}
