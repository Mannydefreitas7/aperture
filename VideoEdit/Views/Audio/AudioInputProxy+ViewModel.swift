//
//  AudioInputProxy+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//

import SwiftUI

extension AudioInputProxy {

    /// An observable view model that bridges an `AVCaptureAudioMonitor` to SwiftUI views,
    /// exposing real-time audio level metrics suitable for visualization.
    ///
    /// Responsibilities:
    /// - Starts and stops monitoring via an `AVCaptureAudioMonitor`.
    /// - Periodically polls the monitor for the current audio snapshot (~30 fps).
    /// - Publishes the instantaneous `level` and rolling `history` for UI consumption.
    @Observable
    @MainActor
    final class ViewModel {

        /// `level` represents the most recent normalized audio level (e.g., 0...1).
        var level: Double = 0
        /// `history` contains a recent sequence of normalized levels for rendering trends.
        var history: [Double] = []
        
        /// `AVCaptureAudioMonitor` for capturing and snapshotting audio levels.
        private let monitor: AVCaptureAudioMonitor = .init()
        /// The polling interval is approximately 33 ms (~30 frames per second).
        private var pollTask: Task<Void, Never>?

        /// Function `start(with:)`: begins the underlying monitor and launches a polling task that updates
        ///  `level` and `history` on a regular cadence.
        /// - Parameter engine: `CaptureEngine`
        func start(with engine: CaptureEngine) async {
            /// Stops previous task if applicable
            await stop()
            /// Configures and runs the underlying capture session used by the monitor.
           // pollTask = await monitor.start(with: engine)
            let snapshot = await monitor.snapshot()
            logger.debug("SNAPSHOT: \(snapshot.level)")
//            pollTask?.cancel()
//            pollTask = Task { [weak self] in
//                guard let self else { return }
//                while !Task.isCancelled {
//                    let snap = await monitor.snapshot()
//                  
//                    self.level = snap.level
//                    self.history = snap.history
//                    try? await Task.sleep(nanoseconds: 33_000_000) // ~30fps
//                }
//            }
        }

        func stop() async {
            pollTask?.cancel()
            pollTask = nil
            await monitor.stop()
        }
    }
}
