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


struct GlassToolBarButtonStyle: PrimitiveButtonStyle {

    var glass: AnyGlassStyle? = nil
    @State private var isPressed: Bool = false
    @State private var _isHovered: Bool = false

    init(glass: AnyGlassStyle? = nil) {
        self.glass = glass
    }

    @Environment(\.controlSize) private var controlSize

    func makeBody(configuration: Configuration) -> some View {

        Button(role: configuration.role) {
            isPressed = true
            configuration.trigger()
            Task.perform(after: 0.1) { isPressed = false }
        } label: {
            configuration.label
                .foregroundStyle(Color(.labelColor))
                .onHover { isHovered in
                    withAnimation {
                        _isHovered = isHovered
                    }
                }
        }
    
        .if(glass != nil) { button in

            switch glass {

                case .regular:
                    button
                        .buttonStyle(.glass)

                case .prominent(let style):
                    button
                        .buttonStyle(.glassProminent)
                        .tint(style)

                case .identity:
                    button.buttonStyle(.accessoryBar)

                default:
                    button.buttonStyle(.accessoryBar)

            }

        } else: { $0.buttonStyle(.accessoryBar) }
    }

}


struct RecordButtonStyle: PrimitiveButtonStyle {

    @State private var isPressed: Bool = false
    @State private var _isHovered: Bool = false
    @Environment(\.controlSize) var controlSize


    func makeBody(configuration: Configuration) -> some View {

        Button(role: configuration.role) {
            isPressed = true
            configuration.trigger()
            Task.perform(after: 0.1) { isPressed = false }
        } label: {
            configuration.label
                .foregroundStyle(Color(.labelColor))
                .onHover { isHovered in
                    withAnimation {
                        _isHovered = isHovered
                    }
                }
        }
        .buttonStyle(.accessoryBar)
    }

}



enum AnyGlassStyle {
    case regular
    case prominent(Color)
    case identity
    case none
}


struct PushDownButtonStyle: PrimitiveButtonStyle {

    var glass: AnyGlassStyle? = nil
    @State private var isPressed: Bool = false
    @State private var _isHovered: Bool = false
    init(glass: AnyGlassStyle? = nil) {
        self.glass = glass
    }

    func makeBody(configuration: Configuration) -> some View {

      Button(role: configuration.role) {
          isPressed = true
          configuration.trigger()
          Task.perform(after: 0.1) { isPressed = false }
        } label: {
            configuration.label
                .onHover { isHovered in
                    withAnimation {
                        _isHovered = isHovered
                    }
                }
        }
        .conditionalEffect(
            .pushDown,
            condition: isPressed
        )
        .if(glass != nil) { button in
            switch glass {
            case .regular:
                    button
                        .buttonStyle(.glass)

            case .prominent(let style):
                    button
                        .buttonStyle(.glassProminent)
                        .tint(style)

            default:
                    button.buttonStyle(.accessoryBar)
            }
        } else: { button in
            button.buttonStyle(.accessoryBar)
        }
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

