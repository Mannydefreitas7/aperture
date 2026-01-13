//
//  Toggle.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import Shimmer

struct RecordToggleStyle: ToggleStyle {

    @State private var isPressed: Bool = false
    @State private var _isHovered: Bool = false

    var gradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [.white.exposureAdjust(-20), .clear]),
            center: .bottomTrailing,
            startRadius: 30,
            endRadius: 30)
    }

    var fraction: CGFloat {
        .init(.recordWidth / 1.2)
    }

    @ViewBuilder
    func recordShape(_ isOn: Bool) -> some View {
        RoundedRectangle(cornerRadius: isOn ? 7 : 999, style: .continuous)
            .fill(
                .shadow(
                    .inner(
                        color: isOn ? .white.exposureAdjust(-10) : .recordingRed.exposureAdjust(-10),
                        radius: 3,
                        x: 3,
                        y: 3
                    )
                )
                .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
            )
            .foregroundColor(Color(red: 236/255, green: 234/255, blue: 235/255))
    }

    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.bouncy) {
                configuration.isOn.toggle()
            }
        } label: {
            Label {
                configuration.label
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    //.font(.title3)
                    .shimmering(
                        active: configuration.isOn,
                        animation: Shimmer.defaultAnimation.speed(1.5),
                        gradient: .init(colors: [.white.opacity(0.7), .white, .white, .white.opacity(0.7)])
                    )

            } icon: {
                    Image(systemName: configuration.isOn ? "square.fill" : "record.circle")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title)
                        .scaleEffect(configuration.isOn ? 0.8 : 1.2)
                        .foregroundStyle(configuration.isOn ? .white : .recordingRed)
            }
            .offset(x: -8)
            .padding(.small)
        }
        .buttonBorderShape(.capsule)
    }
}
