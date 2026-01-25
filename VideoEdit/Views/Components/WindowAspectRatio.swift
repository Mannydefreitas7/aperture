//
//  WindowAspectRatioLock.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//

import SwiftUI
import AppKit


 struct WindowAspectRatio: NSViewRepresentable {
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
