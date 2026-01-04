//
//  EnvironmentValues.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-03.
//


import SwiftUI

struct WindowBox {
    weak var value: NSWindow?
}

struct NSWindowEnvironmentKey: EnvironmentKey {
    typealias Value = WindowBox
    static var defaultValue = WindowBox(value: nil)
}

private struct WorkspaceFullscreenStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var window: WindowBox {
        get { self[NSWindowEnvironmentKey.self] }
        set { self[NSWindowEnvironmentKey.self] = newValue }
    }
    var isFullscreen: Bool {
        get { self[WorkspaceFullscreenStateEnvironmentKey.self] }
        set { self[WorkspaceFullscreenStateEnvironmentKey.self] = newValue }
    }
}
