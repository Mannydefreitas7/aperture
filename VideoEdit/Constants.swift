//
//  Constants.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-01.
//
import SwiftUI

class Constants {

    enum Windows: String, Hashable {
        case main = "main"
        case settings = "settings"
        case welcome = "welcome"
    }

    enum SceneID: String, CaseIterable, Hashable {
        case welcome
        case about
        case editor
        case settings
    }

    struct Assets {
        static let appIcon = NSApplication.shared.applicationIconImage.suggestedFilename ?? "AppIcon"
    }

    static let screen_capture_security_key: String = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

}
