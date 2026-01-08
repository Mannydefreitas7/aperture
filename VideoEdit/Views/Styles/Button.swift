//
//  Button.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-03.
//
import SwiftUI
import Pow

struct WelcomeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        @ViewBuilder var buttonBody: some View {
            let base = configuration.label
                .contentShape(Rectangle())
                .padding(.vertical, 7)
                .padding(.leading, 14)
                .frame(height: 36)
                .background(Color(.labelColor).opacity(configuration.isPressed ? 0.1 : 0.05))

            if #available(macOS 26, *) {
                base.clipShape(Capsule())
            } else {
                base.clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        return buttonBody
    }
}

struct PushDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .conditionalEffect(
                .pushDown,
                condition: configuration.isPressed
            )
            .buttonStyle(.glass)
    }
}

struct ShineEffectButtonStyle: ButtonStyle {

   @Binding var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(.interactiveSpring, value: isEnabled)
            .changeEffect(
                .shine.delay(0.5),
                value: isEnabled,
                isEnabled: isEnabled
            )

    }
}
