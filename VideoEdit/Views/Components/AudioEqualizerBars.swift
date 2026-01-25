//
//  AudioEqualizerBars.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//

import SwiftUI
import Combine

struct AudioEqualizerBars: View {

    @Environment(\.audioInputWaveHistory) private var history

    var barWidth: CGFloat = 6
    var barSpacing: CGFloat = 4
    var minBarHeight: CGFloat = 2
    var maxBarHeight: CGFloat = 80
    var cornerRadius: CGFloat = 3

    /// Peak-hold behavior
    var peakThickness: CGFloat = 2
    var peakHoldDecayPerSecond: CGFloat = 90   // points/sec
    var tickInterval: TimeInterval = 1.0 / 30.0

    @State private var peaks: [CGFloat] = []

    private var tick: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: tickInterval, on: .main, in: .common).autoconnect()
    }

    var body: some View {
        HStack(alignment: .center, spacing: barSpacing) {
            ForEach(history.indices, id: \.self) { idx in
                let v = history[idx]
                let h = clampedHeight(for: v)
                let peak = peakHeight(at: idx, fallback: h)

                ZStack {
                    // Center line reference (optional; comment out if you don’t want it)
                    // Rectangle().frame(height: 1)

                    // Mirrored bar
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .frame(width: barWidth, height: h)
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .frame(width: barWidth, height: h)
                    }

                    // Peak hold markers (top + bottom)
                    VStack(spacing: 0) {
                        // Top peak marker
                        RoundedRectangle(cornerRadius: peakThickness / 2)
                            .frame(width: barWidth, height: peakThickness)
                            .offset(y: -(h - peak) - peakThickness / 2)

                        Spacer(minLength: 0)

                        // Bottom peak marker
                        RoundedRectangle(cornerRadius: peakThickness / 2)
                            .frame(width: barWidth, height: peakThickness)
                            .offset(y: (h - peak) + peakThickness / 2)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(height: maxBarHeight * 2) // mirrored: top + bottom
                .animation(.easeOut(duration: 0.10), value: h)
            }
        }
        .onAppear { syncPeaksCount() }
        .onChange(of: history) { _ in
            syncPeaksCount()
            updatePeaksFromCurrentHeights()
        }
        .onReceive(tick) { _ in
            decayPeaks()
        }
    }

    // MARK: - Helpers

    private func clampedHeight(for normalized: Double) -> CGFloat {
        let h = CGFloat(normalized) * maxBarHeight
        return min(max(minBarHeight, h), maxBarHeight)
    }

    private func peakHeight(at index: Int, fallback: CGFloat) -> CGFloat {
        guard index < peaks.count else { return fallback }
        return peaks[index]
    }

    private func syncPeaksCount() {
        if peaks.count == history.count { return }
        if peaks.count < history.count {
            peaks.append(contentsOf: Array(repeating: minBarHeight, count: history.count - peaks.count))
        } else {
            peaks.removeLast(peaks.count - history.count)
        }
    }

    private func updatePeaksFromCurrentHeights() {
        guard peaks.count == history.count else { return }
        for i in history.indices {
            let h = clampedHeight(for: history[i])
            peaks[i] = max(peaks[i], h) // peak-hold
        }
    }

    private func decayPeaks() {
        guard !peaks.isEmpty else { return }
        let decay = peakHoldDecayPerSecond * CGFloat(tickInterval)

        for i in peaks.indices {
            peaks[i] = max(minBarHeight, peaks[i] - decay)
        }
    }
}
