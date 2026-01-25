//
//  CaptureEngineAudioLevelProcessor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//


import AVFoundation
import Accelerate


actor AVCaptureAudioMonitor {

    private(set) var level: Double = 0
    private(set) var history: [Double] = []

    private var task: Task<Void, Never>?

    private let historyCapacity: Int
    private let smoothing: Double
    private let gain: Double

    init(historyCapacity: Int = 48, smoothing: Double = 0.75, gain: Double = 18.0) {
        self.historyCapacity = max(8, historyCapacity)
        self.smoothing = min(max(smoothing, 0), 0.98)
        self.gain = max(0.1, gain)
    }

    func start(using stream: AsyncStream<CMSampleBuffer>) -> Task<Void, Never> {

        /// Stop method in case the stream is currently running.
        stop()

        let _task = Task(priority: .userInitiated) { [weak self] in
            guard let gain = self?.gain else { return }

            for await sbuf in stream {
                if Task.isCancelled { break }
                let rms = Self.rms(from: sbuf)
                let normalized = min(max(rms * gain, 0), 1)
                await self?.push(normalized)
            }
        }

        task = _task
        return _task
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    func snapshot() -> (level: Double, history: [Double]) {
        (level, history)
    }

    private func push(_ newLevel: Double) async {
        let smoothed = (level * smoothing) + (newLevel * (1 - smoothing))

        var nextHistory = history
        nextHistory.append(smoothed)
        if nextHistory.count > historyCapacity {
            nextHistory.removeFirst(nextHistory.count - historyCapacity)
        }

        level = smoothed
        history = nextHistory
    }

    private static func rms(from sampleBuffer: CMSampleBuffer) -> Double {
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else { return 0 }
        guard let asbdPtr = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else { return 0 }
        let asbd = asbdPtr.pointee

        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return 0 }

        var lengthAtOffset: Int = 0
        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?

        let status = CMBlockBufferGetDataPointer(
            blockBuffer,
            atOffset: 0,
            lengthAtOffsetOut: &lengthAtOffset,
            totalLengthOut: &totalLength,
            dataPointerOut: &dataPointer
        )

        guard status == kCMBlockBufferNoErr,
              let dataPointer,
              totalLength > 0 else { return 0 }

        // Common cases from AVCaptureAudioDataOutput:
        // - 16-bit signed int PCM
        // - 32-bit float PCM
        let isFloat = (asbd.mFormatFlags & kAudioFormatFlagIsFloat) != 0
        let bytesPerFrame = Int(asbd.mBytesPerFrame)
        let channels = Int(asbd.mChannelsPerFrame)
        guard bytesPerFrame > 0, channels > 0 else { return 0 }

        // Treat interleaved samples as one long vector.
        if isFloat {
            let sampleCount = totalLength / MemoryLayout<Float>.size
            guard sampleCount > 0 else { return 0 }

            let floatPtr = dataPointer.withMemoryRebound(to: Float.self, capacity: sampleCount) { $0 }

            var sumSquares: Float = 0
            vDSP_svesq(floatPtr, 1, &sumSquares, vDSP_Length(sampleCount))
            let meanSquares = sumSquares / Float(sampleCount)
            return Double(sqrt(meanSquares))
        } else {
            // Assume signed integer PCM (typically Int16)
            if asbd.mBitsPerChannel == 16 {
                let sampleCount = totalLength / MemoryLayout<Int16>.size
                guard sampleCount > 0 else { return 0 }

                let int16Ptr = dataPointer.withMemoryRebound(to: Int16.self, capacity: sampleCount) { $0 }

                // Convert to float in [-1, 1] then compute RMS.
                var floatBuf = [Float](repeating: 0, count: sampleCount)
                vDSP_vflt16(int16Ptr, 1, &floatBuf, 1, vDSP_Length(sampleCount))

                var scale: Float = 1.0 / Float(Int16.max)
                vDSP_vsmul(floatBuf, 1, &scale, &floatBuf, 1, vDSP_Length(sampleCount))

                var sumSquares: Float = 0
                vDSP_svesq(floatBuf, 1, &sumSquares, vDSP_Length(sampleCount))
                let meanSquares = sumSquares / Float(sampleCount)
                return Double(sqrt(meanSquares))
            } else {
                // Fallback: unknown integer depth
                return 0
            }
        }
    }
}
