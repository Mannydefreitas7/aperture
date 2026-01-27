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

    @Binding var device: DeviceInfo
    @ViewBuilder var content: () -> Content
    @Preference(\.audioVolume) var audioVolume
    @Environment(\.audioInputWave) var audioInputWave

    init(for device: Binding<DeviceInfo>, content: @escaping () -> Content) {
        self._device = device
        self.content = content
    }

    var body: some View {

        LazyVStack(alignment: .leading, spacing: .medium) {

                HStack(alignment: .center, spacing: .medium) {

                    Image("mic")
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageWidth)

                    VStack(alignment: .leading) {
                        Text("Device")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(device.name.capitalized)
                            .font(.headline)
                            .bold()
                    }
                }

                VStack(alignment: .leading, spacing: .small) {

                    let pillWidthSpace: CGFloat = CGSize.pill.width + .spacing
                    let segments = .popoverWidth / pillWidthSpace

                    SegmentedPillBar(
                        value: audioInputWave,
                        segments: Int(segments)
                    )
                    .padding(.leading, .medium)
                    HStack {
                        Button {
                           // device.volume
                        } label: {
                            Image(
                                systemName: symbolName
                            )
                            .contentTransition(.symbolEffect(.automatic)) // macOS-safe
                            .animation(.easeInOut, value: symbolName)
                        }

                        .buttonBorderShape(.capsule)
                        .buttonStyle(.accessoryBar)

                        Slider(value: $device.volume, in: 0...1)
                            .onChange(of: device.volume) { oldValue, newValue in
                                audioVolume = newValue
                            }

                    }
                    .padding(.top, .small / 2)
                    .controlSize(.regular)
                    .onAppear {
                        device.volume = audioVolume
                    }
                    .frame(minHeight: .extraLarge)
                }
            }
            .frame(width: .popoverWidth)
            .overlay(alignment: .topTrailing) {
                content()
                    .offset(x: .small, y: -.small)
            }
    }

    private func adjust(_ delta: Double) {
        let volume = min(1.0, max(0.0, device.volume + delta))
        print(volume)
        device.volume = min(1.0, max(0.0, device.volume + delta))
    }
}



// MARK: - Segmented Pills

struct SegmentedPillBar: View {
    var value: Float
    var segments: Int

    var size: CGSize = .pill

    private var activeCount: Int {
        Int((value * Float(segments)).rounded(.toNearestOrAwayFromZero))
    }

    var body: some View {
        HStack(spacing: .spacing) {
            ForEach(0..<segments, id: \.self) { i in
                Capsule(style: .continuous)
                    .fill(fillColor(for: i))
                    .frame(width: size.width, height: size.height)
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

extension VolumeHUD {

    var symbolName: String {
        switch device.volume {
            case 0:
                return "speaker.slash.fill"
            case 0..<0.33:
                return "speaker.wave.1.fill"
            case 0..<0.66:
                return "speaker.wave.2.fill"
            default:
                return "speaker.wave.3.fill"
        }
    }

    private var imageWidth: CGFloat { .thumbnail / 2.5 }
    private var maxValue: CGFloat { 3 }
    private var segmentedPill: CGFloat { .small * maxValue }
    private var volume: Int { Int(device.volume) }
    private var percentText: String { "\(Int((device.volume * 100).rounded()))%" }

}
