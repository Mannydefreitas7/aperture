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
    typealias NSViewType = VideoPreviewView
    let session: AVCaptureSession

    public class VideoPreviewView: NSView {
        var previewLayer: AVCaptureVideoPreviewLayer? {
            layer as? AVCaptureVideoPreviewLayer
        }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }

        override func makeBackingLayer() -> CALayer {
            AVCaptureVideoPreviewLayer()
        }

        override func layout() {
            super.layout()
            previewLayer?.frame = bounds
            layer = previewLayer
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    public init(session: AVCaptureSession) {
        self.session = session
      //  self.sessionLayer = AVCaptureVideoPreviewLayer(session: session)
    }

    func makeNSView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.layer?.backgroundColor = .black
        view.previewLayer?.videoGravity = .resizeAspectFill
        view.previewLayer?.session = session
        return view
    }
    
    func updateNSView(_ nsView: VideoPreviewView, context: Context) {
        nsView.previewLayer?.videoGravity = .resizeAspectFill
        nsView.previewLayer?.frame = nsView.bounds
    }
}

struct VideoInputPreview: NSViewRepresentable {
    typealias NSViewType = PlayerView
    
    private var dbags = [AnyCancellable]()
    private var source: PreviewSource
    private var session: AVCaptureSession?

    var isRecording: Bool = false
    var outputURL: URL? = nil
    var captureError: CaptureError? = nil

    @Preference(\.isMirrored) private var isMirror

    init(session: AVCaptureSession) {
        self.source = DefaultPreviewSource(session: session)
    }

    func makeNSView(context: Context) -> PlayerView {
        let player = PlayerView()
        source.connect(to: player)
        return player
    }

    func updateNSView(_ nsView: PlayerView, context: Context) {

        guard let previewLayer = nsView.previewLayer,
              let connection = previewLayer.connection else { return }

        Task { @MainActor in
            connection.automaticallyAdjustsVideoMirroring = false
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = isMirror
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, AVCaptureFileOutputRecordingDelegate {

        var previewLayer: AVCaptureVideoPreviewLayer?
        var isRecording: Bool = false
        var outputURL: URL? = nil
        var captureError: CaptureError? = nil

            // Required delegate method
        func fileOutput(
            _ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
                guard error != nil else {
                    Task { @MainActor in
                        captureError = .outputFileNotFound(url: outputFileURL, reason: "")
                    }
                    return
                }
                print("Successfully saved to: \(outputFileURL.path)")
                Task { @MainActor in
                    isRecording = false
                    outputURL = outputFileURL
                }
            }

            // Optional: UI sync method
        func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
            print("Recording started!")
            Task { @MainActor in
                isRecording = true
                outputURL = fileURL
            }
        }
    }
}

extension VideoInputPreview {

    class PlayerView: NSView, PreviewTarget {
        private var dbags = [AnyCancellable]()

        var previewLayer: AVCaptureVideoPreviewLayer? {
            layer as? AVCaptureVideoPreviewLayer
        }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            setupLayer()
        }

        override func makeBackingLayer() -> CALayer {
            AVCaptureVideoPreviewLayer()
        }

        override func layout() {
            super.layout()
            previewLayer?.frame = bounds
        }

        private func setupLayer() {
            previewLayer?.contentsGravity = .resizeAspectFill
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.connection?.automaticallyAdjustsVideoMirroring = true
        }

        nonisolated func setSession(_ session: AVCaptureSession) {
            // Connects the session with the preview layer, which allows the layer
            // to provide a live view of the captured content.
            Task { @MainActor in
                previewLayer?.session = session
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
