//
//  DeviceDelegate+Protocol.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//


/// A protocol that standardizes how capture input delegates handle CMSampleBuffer delivery
/// from AVFoundation capture outputs.
///
/// Types conforming to `AVInputDelegate` typically act as adapters between
/// `AVCaptureOutput` instances (such as `AVCaptureVideoDataOutput` or
/// `AVCaptureAudioDataOutput`) and your app’s processing pipeline. Implementers
/// receive sample buffers in real time and can forward, transform, or analyze
/// them as needed.
protocol DeviceDelegate {

    associatedtype AVDelegateOutput
    /// The capture connection associated with the current sample buffer.
    ///
    /// This connection provides context such as enabled video stabilization,
    /// orientation, and whether the connection is active. It is typically supplied
    /// by AVFoundation when invoking the processing callback and can be stored
    /// for reference during subsequent processing steps.
    var connection: AVCaptureConnection? { get set }

    /// The capture output that produced the sample buffer.
    ///
    /// This is commonly an `AVCaptureVideoDataOutput` or `AVCaptureAudioDataOutput`.
    /// Holding a reference can be useful for inspecting output-specific settings
    /// (e.g., video settings, audio format) or for correlating buffers to a
    /// particular output in multi-output configurations.
    var output: AVDelegateOutput? { get set }

    /// The most recently received sample buffer.
    ///
    /// Conformers may cache the last buffer to support pull-based consumers
    /// or to enable late processing steps. Be mindful of buffer lifetimes and
    /// avoid holding onto buffers longer than necessary.
    var sampleBuffer: CMSampleBuffer? { get set }

    var url: URL? { get set }

    /// Handles a newly delivered sample buffer from an `AVCaptureOutput`.
    ///
    /// Implement this method to perform your per-buffer work, such as:
    /// - Decoding, transforming, or filtering video frames.
    /// - Measuring audio levels or performing audio analysis.
    /// - Forwarding buffers to encoders, recorders, or streaming pipelines.
    ///
    /// - Parameters:
    ///   - output: The `AVCaptureOutput` instance that produced the buffer.
    ///   - sampleBuffer: The `CMSampleBuffer` containing media data and timing info.
    ///   - connection: The `AVCaptureConnection` through which the buffer was delivered.
    ///
    /// - Important: This method may be called on a background queue. If you need
    ///   to interact with UI or other main-actor-only APIs, dispatch appropriately.
    func process(
        output: AVDelegateOutput?,
        sampleBuffer: CMSampleBuffer?,
        url: URL?,
        connection: AVCaptureConnection?
    )
}
