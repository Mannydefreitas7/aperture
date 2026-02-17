//
//  AudioCapture.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-29.
//

import Foundation
import AVFoundation
import Combine

/// An object that manages a movie capture output to record videos.
final class AudioCapture: OutputService {
    //
    typealias Output = AVCaptureAudioFileOutput

    var output: AVCaptureAudioFileOutput = AVCaptureAudioFileOutput()
    var captureActivity: CaptureActivity = .idle
    var capabilities: CaptureCapabilities = .unknown

}

/// Audio capture preview output
final class AudioCapturePreview: OutputService {

    typealias Output = AVCaptureAudioPreviewOutput

    var output: AVCaptureAudioPreviewOutput = AVCaptureAudioPreviewOutput()
    var captureActivity: CaptureActivity = .idle
    var capabilities: CaptureCapabilities = .unknown
}
