//
//  View+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//

import SwiftUI


extension View {
    /// Injects a live `Binding<NSWindow.StyleMask>` for the current window into the environment.
    /// Also keeps `EnvironmentValues.styleMask` in sync with the binding's value.
    func styleMask(_ styles: NSWindow.StyleMask) -> some View {
        modifier(WindowStyleMask(mask: .constant(styles)))
    }

    func styleMask(_ styles: Binding<NSWindow.StyleMask>) -> some View {
        modifier(WindowStyleMask(mask: styles))
    }

    func onDisplay(layer: Binding<Layer>, action: @escaping () -> Void) -> some View {
        onAppear {
            layer.visibility.wrappedValue = .visible
            action()
        }
    }

    func onDisplay(layer: Binding<Layer>) -> some View {
        onAppear {
            layer.wrappedValue.visibility = .visible
        }
    }

    func onDisplay(action: @escaping () -> Void) -> some View {
        onAppear(perform: action)
    }

    func onDisappear(layer: Binding<Layer>) -> some View {
        onDisappear {
            layer.wrappedValue.visibility = .hidden
        }
    }
}

