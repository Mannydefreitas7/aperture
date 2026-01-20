//
//  AudioVolume.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-11.
//

import SwiftUI
import AVFoundation

// MARK: - Public Component

struct VolumeHUD<Content: View>: View {
    @Binding var volume: Double
    var connectedDevice: DeviceInfo?
    var content: () -> Content

    private var percentText: String { "\(Int((volume * 100).rounded()))%" }
    private let imageWidth: CGFloat = .thumbnail / 2
    private let segmentedPill: CGFloat = .small * 3



    var body: some View {

            LazyVStack(spacing: .medium) {

                HStack(alignment: .center, spacing: .medium) {
                    VStack {
                        Image("mic")
                            .resizable()
                            .scaledToFit()
                            .frame(height: imageWidth)

                        Spacer()

                        content()
                    }

                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Device")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)

                                Text(connectedDevice?.name.capitalized ?? "Unknown")
                                    .font(.headline)
                                    .bold()
                            }

                            Spacer()

                            Button("Change", systemImage: "microphone.badge.ellipsis") {
                                //
                            }
                            .buttonStyle(.accessoryBarAction)
                            .offset(x: (.small))
                        }

                        VStack(alignment: .leading, spacing: .small) {

                            let pillWidthSpace: CGFloat = .pillWidth + .small
                            let segments = .popoverWidth / pillWidthSpace

                            SegmentedPillBar(
                                value: volume,
                                segments: Int(segments)
                            )
                            HStack {
                                Image(systemName: volume >= 1 ? "volume.\(volume).fill" : "volume.fill")
                                Slider(value: $volume, in: 0...3)
                            }

                                .padding(.top, .small / 2)
                                .controlSize(.mini)
                        }
                    }
                }
            }
            .frame(width: .popoverWidth)


    }

    private func adjust(_ delta: Double) {
        volume = min(1.0, max(0.0, volume + delta))
    }
}



// MARK: - Segmented Pills

struct SegmentedPillBar: View {
    var value: Double
    var segments: Int
    var pillWidth: CGFloat = .pillWidth
    var pillHeight: CGFloat = 18
    var spacing: CGFloat = .spacing

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

//// MARK: - Preview
//
//struct VolumeHUD_Previews: PreviewProvider {
//    struct Demo: View {
//        @State private var volume = 0.70
//        var body: some View {
//            VolumeHUD(volume: $volume, connectedDevice: <#T##DeviceInfo#>)
//        }
//    }
//
//    static var previews: some View {
//        Demo()
//            .frame(width: .popoverWidth)
//            .previewLayout(.sizeThatFits)
//    }
//}
