//
//  Constants.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-01.
//

class Constants {

    enum Windows: String, Hashable {
        case main = "main"
        case settings = "settings"
        case welcome = "welcome"
    }

    static let screen_capture_security_key: String = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

}
