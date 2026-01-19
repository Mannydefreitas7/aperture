//
//  AVCapture+Delegate.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/18/26.
//
import AVFoundation

// MARK: - Delegates

final class VideoOutputDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let onFrame: (CMSampleBuffer) -> Void
    init(onFrame: @escaping (CMSampleBuffer) -> Void) { self.onFrame = onFrame }
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        onFrame(sampleBuffer)
    }
}

final class AudioOutputDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    private let onSample: (CMSampleBuffer) -> Void
    init(onSample: @escaping (CMSampleBuffer) -> Void) { self.onSample = onSample }
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        onSample(sampleBuffer)
    }
}
