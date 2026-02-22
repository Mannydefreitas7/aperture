//
//  VideoInut+Preview.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//

import AVFoundation
import SwiftUI
import Combine

struct VideoPreview: NSViewRepresentable {
    typealias NSViewType = VideoInputNSView
    @Binding var viewModel: VideoInputView.ViewModel

    func makeNSView(context: Context) -> VideoInputNSView {
        let view = VideoInputNSView()
        view.session = viewModel.currentSession
        viewModel.previewLayer = view.previewLayer
        Task { @MainActor in
            viewModel.isConnecting = true
        }
        return view
    }

    func updateNSView(_ nsView: VideoInputNSView, context: Context) {
        //nsView.session = viewModel.currentSession
        toggleMirroring(nsView.previewLayer)

        if let isActive = nsView.previewLayer?.isHidden {
            Task { @MainActor in
                viewModel.isConnecting = !isActive
            }
        }
    }

    func toggleMirroring(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        guard let previewLayer, let connection = previewLayer.connection else {
            return
        }
        connection.automaticallyAdjustsVideoMirroring = false
        if connection.isVideoMirroringSupported {
            previewLayer.connection?.isVideoMirrored = viewModel.isMirrored
        }
    }
}
