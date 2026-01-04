//
//  AppKit+Extensions.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-03.
//

import AppKit
import SwiftUI

extension OpenWindowAction {
    func callAsFunction(sceneID: Constants.SceneID) {
        callAsFunction(id: sceneID.rawValue)
    }
}

extension NSApplication {
    func closeWindow(_ id: Constants.SceneID) {
        windows.first { $0.identifier?.rawValue == id.rawValue }?.close()
    }

    func closeWindow(_ ids: Constants.SceneID...) {
        ids.forEach { id in
            windows.first { $0.identifier?.rawValue == id.rawValue }?.close()
        }
    }

    func findWindow(_ id: Constants.SceneID) -> NSWindow? {
        windows.first { $0.identifier?.rawValue == id.rawValue }
    }

    var openSwiftUIWindows: Int {
        NSApp
            .windows
            .compactMap(\.identifier?.rawValue)
            .compactMap { Constants.SceneID(rawValue: $0) }
            .count
    }
}
