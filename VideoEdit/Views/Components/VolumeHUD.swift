//
//  AudioVolume.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-11.
//

import SwiftUI

// MARK: - Public Component

struct VolumeHUD: View {
    @Binding var volume: Double
    var connectedDevice: String = "Xchyle’s Airpods"

    private var percentText: String { "\(Int((volume * 100).rounded()))%" }
    private let imageWidth: CGFloat = .thumbnail / 2
    private let segmentedPill: CGFloat = 18


    var body: some View {

            VStack(spacing: .medium) {

                HStack(alignment: .center, spacing: .large) {
                    Image("mic")
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageWidth)

                    VStack(alignment: .leading) {
                        Text("Name long")
                            .font(.title3)
                        Text("Description long")
                            .font(.subheadline)

                        VStack(alignment: .leading, spacing: .small) {

                            let _width: CGFloat = .popoverWidth
                            let segments = _width / segmentedPill

                            SegmentedPillBar(
                                value: volume,
                                segments: Int(segments)
                            )
                            Slider(value: $volume, in: 0...1)
                                .frame(width: .popoverWidth)
                                .padding(.top, .small)
                        }
                    }
                }

                Menu {
                    Text("Mic 1")
                    Text("Mic 1")
                    Text("Mic 1")
                    Text("Mic 1")
                } label: {
                    Label(connectedDevice, systemImage: "microphone.badge.ellipsis")
                        .font(.title3)
                }
                .menuStyle(.button)
                .controlSize(.extraLarge)
            }
            .padding(segmentedPill * 1.5)


    }

    private func adjust(_ delta: Double) {
        volume = min(1.0, max(0.0, volume + delta))
    }
}



// MARK: - Segmented Pills

struct SegmentedPillBar: View {
    var value: Double
    var segments: Int
    var pillWidth: CGFloat = 12
    var pillHeight: CGFloat = 18
    var spacing: CGFloat = 6

    private var activeCount: Int {
        Int((value * Double(segments)).rounded(.toNearestOrAwayFromZero))
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<segments, id: \.self) { i in
                Capsule(style: .continuous)
                    .fill(fillColor(for: i))
                    .frame(width: pillWidth, height: pillHeight)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .glassEffect()
            }
        }
    }

    private func fillColor(for index: Int) -> Color {
        if index < activeCount {
            // Green -> Yellow ramp like the design
            // (Hue ~ 0.30 = green, to ~ 0.14 = yellow)
            let t = segments <= 1 ? 0 : Double(index) / Double(segments - 1)
            let hue = (0.30 - (0.24 * t)) // 0.30 -> 0.14
            return Color(hue: hue, saturation: 0.95, brightness: 0.95)
        } else {
            return Color.white.opacity(0.25)
        }
    }
}

// MARK: - Preview

struct VolumeHUD_Previews: PreviewProvider {
    struct Demo: View {
        @State private var volume = 0.70
        var body: some View {
           // VStack(spacing: 24) {
                VolumeHUD(volume: $volume, connectedDevice: "Xchyle’s Airpods")
            //}
        }
    }

    static var previews: some View {
        Demo()
            .frame(width: .popoverWidth)
            .previewLayout(.sizeThatFits)
    }
}
