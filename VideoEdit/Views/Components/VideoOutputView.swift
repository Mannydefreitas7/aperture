//
//  VideoOutputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//
import AVFoundation
import SwiftUI
import Combine

struct VideoOutputView: NSViewRepresentable {
    typealias NSViewType = PlayerView

    var captureSession: AVCaptureSession
    
    @Preference(\.isMirrored) private var isMirror

    func makeNSView(context: Context) -> PlayerView {
        let player = PlayerView(captureSession: captureSession)
        guard let previewLayer = player.previewLayer, let connection = previewLayer.connection, connection.isVideoMirroringSupported else {
            return player
        }

        return player
    }

    func updateNSView(_ nsView: PlayerView, context: Context) {
        guard let previewLayer = nsView.previewLayer, let connection = previewLayer.connection, connection.isVideoMirroringSupported else {
            return
        }

        DispatchQueue.main.async {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = isMirror
        }
    }
}

extension VideoOutputView {

    class PlayerView: NSView {
        var previewLayer: AVCaptureVideoPreviewLayer?
        private var dbags = [AnyCancellable]()

        init(captureSession: AVCaptureSession) {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            super.init(frame: .zero)
            setupLayer()
        }

        func setupLayer() {
            guard let previewLayer else { return }
            previewLayer.frame = self.frame
            previewLayer.isDeferredStartEnabled = true
            previewLayer.contentsGravity = .resizeAspectFill
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.automaticallyAdjustsVideoMirroring = true
            layer = previewLayer
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
