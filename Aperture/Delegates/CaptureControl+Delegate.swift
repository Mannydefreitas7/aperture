//
//  CaptureControlsDelegate.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//
import AVFoundation
import Combine

class CaptureControlsDelegate: NSObject, AVCaptureSessionControlsDelegate {
    
    @Published private(set) var isShowingFullscreenControls = false

    func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
        Console.info("Capture controls active.")
    }

    func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {
        isShowingFullscreenControls = true
        Console.info("Capture controls will enter fullscreen appearance.")
    }
    
    func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {
        isShowingFullscreenControls = false
        Console.info("Capture controls will exit fullscreen appearance.")
    }
    
    func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
        Console.info("Capture controls inactive.")
    }
}
