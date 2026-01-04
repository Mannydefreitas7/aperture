//
//  VICameraCaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import AVFoundation
import AppKit

struct VICameraCaptureView: View {

    @StateObject private var viewModel: ViewModel = .init()
    @AppStorage(
        "VICameraCaptureView.aspectPreset"
    ) private var aspectPresetRawValue: String = AspectPreset.youtube.rawValue
    @AppStorage("VICameraCaptureView.showAspectMask") private var showAspectMask: Bool = true
    @AppStorage("VICameraCaptureView.showSafeGuides") private var showSafeGuides: Bool = true
    @AppStorage("VICameraCaptureView.showPlatformSafe") private var showPlatformSafe: Bool = true

    private var aspectPreset: AspectPreset {
        get { AspectPreset(rawValue: aspectPresetRawValue) ?? .youtube }
        set { aspectPresetRawValue = newValue.rawValue }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CameraPreview(session: $viewModel.session)
                .ignoresSafeArea(.all)
            if showAspectMask {
                AspectMaskOverlay(
                    preset: aspectPreset,
                    showGuides: showSafeGuides,
                    showPlatformSafe: showPlatformSafe
                )
                .ignoresSafeArea(.all)
                .allowsHitTesting(false)
            }



        }
        .toolbarRole(.editor)
        .toolbar(id: "camera-toolbar") {

            ToolbarSpacer()

            ToolbarItem(id: "guide-toggle") {

                Toggle(
                    "Show Guides",
                    systemImage: "squareshape.split.2x2.dotted.inside.and.outside",
                    isOn: $showSafeGuides
                )
                    .help("Show/hide the Guides for the current selected platform")

            }.customizationBehavior(.reorderable)

            ToolbarItem(id: "mask-toggle") {

                Toggle("Show Mask", systemImage: "circle.rectangle.filled.pattern.diagonalline", isOn: $showAspectMask)
                    .help("Show/hide the mask for the current aspect ratio")

            }.customizationBehavior(.reorderable)

            ToolbarItem(id: "aspect-ratio-picker2") {

                Menu {
                    Picker("Ratio", systemImage: "aspectratio", selection: $aspectPresetRawValue) {
                        ForEach(AspectPreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset.rawValue)
                        }
                    }
                    .pickerStyle(.inline)

                } label: {
                    Label {
                        Text("Ratio")
                    } icon: {
                        Image(systemName: "aspectratio")
                    }
                }
                .help("Change the aspect ratio")
            }
            .sharedBackgroundVisibility(.visible)
            .customizationBehavior(.reorderable)




            ToolbarItem(id: "aspect-picker") {
                    Menu {
                        Picker("Aspect", selection: $aspectPresetRawValue) {
                            ForEach(AspectPreset.allCases) { preset in
                                Text(preset.rawValue).tag(preset.rawValue)
                            }
                        }

                        Divider()

                        Toggle("Show Mask", isOn: $showAspectMask)
                        Toggle("Safe Guides", isOn: $showSafeGuides)
                        Toggle("Platform UI Safe", isOn: $showPlatformSafe)
                    } label: {
                        Label {
                            Text("Ratio")
                        } icon: {
                            Image(systemName: "aspectratio")
                        }
                    }
               // }
            }

            //ToolbarItemGroup(placement: .primaryAction) {

            //    ToolbarItem(placement: .primaryAction) {
//                    Menu {
//                        Picker("Aspect", selection: $aspectPresetRawValue) {
//                            ForEach(AspectPreset.allCases) { preset in
//                                Text(preset.rawValue).tag(preset.rawValue)
//                            }
//                        }
//
//                        Divider()
//
//                        Toggle("Show Mask", isOn: $showAspectMask)
//                        Toggle("Safe Guides", isOn: $showSafeGuides)
//                        Toggle("Platform UI Safe", isOn: $showPlatformSafe)
//                    } label: {
//                        HStack(spacing: 8) {
//                            Image(systemName: "rectangle.dashed")
//                            Text(aspectPreset.rawValue)
//                        }
//                        .font(.callout)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 8)
//                    }
//                    .background(.ultraThinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .padding()
               // }
          //  }
        }

        // Keep the window resizable but constrained to 16:9.
        .background(WindowAspectRatioLock(ratio: CGSize(width: 16, height: 9)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


extension VICameraCaptureView {

    enum Mode: String, Hashable {
        case screenshare = "Screenshare"
        case camera = "Camera"
    }

    struct WindowAspectRatioLock: NSViewRepresentable {
        let ratio: CGSize

        final class Coordinator {
            weak var window: NSWindow?
        }

        func makeCoordinator() -> Coordinator { Coordinator() }

        func makeNSView(context: Context) -> NSView {
            let view = NSView(frame: .zero)
            DispatchQueue.main.async {
                guard let window = view.window else { return }
                context.coordinator.window = window
                window.contentAspectRatio = ratio
            }
            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {
            DispatchQueue.main.async {
                guard let window = nsView.window else { return }
                context.coordinator.window = window
                if window.contentAspectRatio != ratio {
                    window.contentAspectRatio = ratio
                }
            }
        }
    }


    enum AspectPreset: String, CaseIterable, Identifiable {
        /// Locks the hosting NSWindow to a fixed content aspect ratio while still allowing resize.

        case youtube = "YouTube"
        case tiktok = "TikTok"
        case instagram = "Instagram"

        var id: String { rawValue }

        var ratio: CGSize {
            switch self {
                case .youtube:
                    // Standard YouTube landscape
                    return CGSize(width: 16, height: 9)
                case .tiktok:
                    // Vertical video
                    return CGSize(width: 9, height: 16)
                case .instagram:
                    // Feed-safe default (4:5)
                    return CGSize(width: 4, height: 5)
            }
        }

        /// Platform UI overlays to avoid (fractions of the target rect size).
        /// Values are approximate guides (not exact platform specs).
        var platformAvoidance: PlatformAvoidance? {
            switch self {
                case .tiktok:
                    // TikTok commonly has UI at the top and a heavier stack at the bottom.
                    return PlatformAvoidance(top: 0.12, bottom: 0.20, left: 0.0, right: 0.0)
                case .instagram:
                    // Instagram feed/reels overlays tend to be lighter than TikTok.
                    return PlatformAvoidance(top: 0.10, bottom: 0.14, left: 0.0, right: 0.0)
                default:
                    return nil
            }
        }

        struct PlatformAvoidance: Equatable {
            var top: CGFloat
            var bottom: CGFloat
            var left: CGFloat
            var right: CGFloat
        }
    }

    /// Visual overlay showing the selected aspect ratio as a centered mask.
    /// The window remains freely resizable; this is purely a guide.
    struct AspectMaskOverlay: View {
        let preset: AspectPreset
        var showGuides: Bool = true
        var showPlatformSafe: Bool = true
        var topPadding: CGFloat = 56   // Approx expanded macOS title bar height
        var bottomPadding: CGFloat = 128
        var dimOpacity: CGFloat = 0.7
        var borderLineWidth: CGFloat = 2
        var cornerRadius: CGFloat = 24

        var body: some View {
            GeometryReader { geo in
                let container = geo.size
                let paddedContainer = CGSize(
                    width: container.width,
                    height: max(0, container.height - topPadding - bottomPadding)
                )

                let target = fittedSize(container: paddedContainer, ratio: preset.ratio)

                let rect = CGRect(
                    x: (container.width - target.width) / 2,
                    y: topPadding + (paddedContainer.height - target.height) / 2,
                    width: target.width,
                    height: target.height
                )

                // Dim everything outside the target rect.
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: container))
                    path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
                }
                .fill(.black.opacity(dimOpacity), style: FillStyle(eoFill: true))

                // Border for the target rect.
                RoundedRectangle(cornerRadius: cornerRadius)
                    .path(in: rect)
                    .stroke(.white.opacity(0.9), lineWidth: borderLineWidth)

                if showPlatformSafe, let avoid = preset.platformAvoidance {
                    // Shade platform UI areas inside the target rect to indicate regions to avoid.
                    if avoid.top > 0 {
                        Rectangle()
                            .path(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * avoid.top))
                            .fill(.black.opacity(0.25))
                    }
                    if avoid.bottom > 0 {
                        Rectangle()
                            .path(in: CGRect(x: rect.minX, y: rect.maxY - (rect.height * avoid.bottom), width: rect.width, height: rect.height * avoid.bottom))
                            .fill(.black.opacity(0.25))
                    }
                    if avoid.left > 0 {
                        Rectangle()
                            .path(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width * avoid.left, height: rect.height))
                            .fill(.black.opacity(0.25))
                    }
                    if avoid.right > 0 {
                        Rectangle()
                            .path(in: CGRect(x: rect.maxX - (rect.width * avoid.right), y: rect.minY, width: rect.width * avoid.right, height: rect.height))
                            .fill(.black.opacity(0.25))
                    }
                }

                if showGuides {
                    // Inner safe guides (e.g., title/action safe).
                    let rect90 = rect.insetBy(dx: rect.width * 0.05, dy: rect.height * 0.05)
                    let rect80 = rect.insetBy(dx: rect.width * 0.10, dy: rect.height * 0.10)

                    RoundedRectangle(cornerRadius: max(0, cornerRadius - 2))
                        .path(in: rect90)
                        .stroke(.white.opacity(0.50), style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))

                    RoundedRectangle(cornerRadius: max(0, cornerRadius - 4))
                        .path(in: rect80)
                        .stroke(.white.opacity(0.52), style: StrokeStyle(lineWidth: 1.5, dash: [4, 6]))

                    // Crosshair guides (subtle).
                    Path { p in
                        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
                        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
                        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                    }
                    .stroke(.white.opacity(0.15), lineWidth: 1)
                }
            }
        }

        private func fittedSize(container: CGSize, ratio: CGSize) -> CGSize {
            guard ratio.width > 0, ratio.height > 0 else { return container }
            let containerAspect = container.width / max(container.height, 1)
            let targetAspect = ratio.width / ratio.height

            // Fit the target rect fully inside the container.
            if containerAspect >= targetAspect {
                // Container is wider than target → limit by height.
                let height = container.height
                let width = height * targetAspect
                return CGSize(width: width, height: height)
            } else {
                // Container is taller than target → limit by width.
                let width = container.width
                let height = width / targetAspect
                return CGSize(width: width, height: height)
            }
        }
    }


    struct CameraPreview: NSViewRepresentable {


        @Binding var session: AVCaptureSession

        func makeNSView(context: Context) -> NSView {
            return PreviewHostingView(session: session)
        }

        func updateNSView(_ uiView: NSView, context: Context) {
            guard let hosting = uiView as? PreviewHostingView else { return }
            hosting.previewLayer.session = session
            hosting.needsLayout = true
            hosting.layoutSubtreeIfNeeded()
        }

        final class PreviewHostingView: NSView {
            let previewLayer: AVCaptureVideoPreviewLayer

            init(session: AVCaptureSession) {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
                super.init(frame: .zero)
                self.wantsLayer = true
                self.layerContentsRedrawPolicy = .duringViewResize
                self.layer?.needsDisplayOnBoundsChange = true
                self.previewLayer.videoGravity = .resizeAspectFill
                self.layer?.addSublayer(previewLayer)
                // Let Core Animation resize the preview layer continuously with the view's backing layer.
                self.previewLayer.frame = self.bounds
                self.previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            }

            @available(*, unavailable)
            required init?(coder: NSCoder) { nil }

            override func layout() {
                super.layout()
                previewLayer.frame = self.bounds
            }

        }
    }


    actor Manager {

        func addAudioInput(_ session: AVCaptureSession) {
            guard let device = AVCaptureDevice.default(for: .audio) else { return }
            guard let input = try? AVCaptureDeviceInput(device: device) else { return }
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }

        func addVideoInput(_ session: AVCaptureSession) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            guard let input = try? AVCaptureDeviceInput(device: device) else { return }
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }


    }

    @MainActor
    class ViewModel: ObservableObject {
        private var manager: Manager = .init()
        @Published var session: AVCaptureSession = .init()
        @Published var mode: Mode = .camera

        init() {
            Task {
                await addInputs()
            }

            if !session.isRunning {
                session.startRunning()
            }
        }

        func addInputs() async {
            await manager.addAudioInput(session)
            await manager.addVideoInput(session)
        }
    }

}

#Preview {
    VICameraCaptureView()
}
