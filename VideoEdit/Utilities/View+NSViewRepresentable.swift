//
//  View+NSViewRepresentable.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-01.
//
import SwiftUI
import AppKit

struct WindowControlsAccessor: NSViewRepresentable {
    var hideClose: Bool
    var hideMinimize: Bool
    var hideZoom: Bool

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }

            window.standardWindowButton(.closeButton)?.isHidden = hideClose
            window.standardWindowButton(.miniaturizeButton)?.isHidden = hideMinimize
            window.standardWindowButton(.zoomButton)?.isHidden = hideZoom

           // window.isMovableByWindowBackground = false
          //  window.titlebarAppearsTransparent = true
          //  window.titleVisibility = .hidden

        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }

            window.standardWindowButton(.closeButton)?.isHidden = hideClose
            window.standardWindowButton(.miniaturizeButton)?.isHidden = hideMinimize
            window.standardWindowButton(.zoomButton)?.isHidden = hideZoom

            //window.isMovableByWindowBackground = false
            //window.titlebarAppearsTransparent = true
         //   window.titleVisibility = .hidden
        }
    }
}


struct WindowCenteredAccessor: NSViewRepresentable {


    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }

            window.center()

        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }

            window.center()
        }
    }
}
