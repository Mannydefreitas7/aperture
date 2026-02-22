//
//  Error+Enum.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import Foundation

enum CaptureError: Error {
    case noVideo
    case noAudio
    case noAudioAndVideo
    case unknown(reason: String)
    case outputFileNotFound(url: URL, reason: String)
}

enum ConnectionError: Error {
    case timeout
    case deviceNotAvailable
    case unknown(reason: String)
}

enum SessionError: Error {
    case alreadyRunning(name: String)
    case notRunning(name: String)
    case deviceAlreadyAdded(name: String, session: String)
    case deviceNotFound(name: String, session: String)
    case unknown(reason: String)
}
