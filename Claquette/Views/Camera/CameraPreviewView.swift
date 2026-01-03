import SwiftUI
import AVFoundation

struct CameraPreviewView: NSViewRepresentable {
    let session: VCCameraSession

    func makeNSView(context: Context) -> NSView {
        let view = CameraPreviewNSView()
        Task {
            view.session = await session.current
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let previewView = nsView as? CameraPreviewNSView else { return }
          Task {
            previewView.session = await session.current
        }
    }
}

class CameraPreviewNSView: NSView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    var session: AVCaptureSession? {
        didSet {
            setupPreviewLayer()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }

    private func setupPreviewLayer() {
        previewLayer?.removeFromSuperlayer()

        guard let session = session else { return }

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds

        self.layer?.addSublayer(layer)
        self.previewLayer = layer
    }
}
