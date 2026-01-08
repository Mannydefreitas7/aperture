//
//  RecordButtonView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-06.
//

import SwiftUI

/// A metallic / shiny neumorphic record button with animated start/stop transition
/// and a press-down interaction.
 struct RecordButton: View {

    @Binding var isRecording: Bool
    @State private var isPressed: Bool = false

    // Use AnyShape to store a shape that can change type
    var currentShape: AnyShape {
        if isRecording  {
            return AnyShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        return  AnyShape(Circle())
    }

    @ViewBuilder
    func labelContent() -> some View {
        ZStack {
            Circle()
                .stroke(Color(.recordingRed), lineWidth: 2)
                .frame(width: CGSize.systemSize.recordButton.width, height: CGSize.systemSize.recordButton.height)
                .scaleEffect(isRecording ? 1 : 0.1)
                .if(isRecording) { view in
                    view
                        .heartBeatAnimation()
                }
                .glassEffect()


            currentShape
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color:
                                Color(.systemRed).exposureAdjust(1),
                                location: 0),
                            .init(color:  Color(.systemRed).exposureAdjust(-2), location: 0.70),
                            .init(color:  Color(.systemRed).exposureAdjust(-3), location: 0.90)
                        ],

                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                .conditionalEffect(
                    .repeat(
                        .glow(
                            color:
                                Color(.systemRed)
                                .exposureAdjust(5),
                            radius: 5
                        ),
                        every: 1.5
                    ),
                    condition: isRecording
                )
                .scaleEffect(isRecording ? 0.5 : 1)
        }
        .glassEffect(isRecording ? .identity : .clear)

    }

    var body: some View {
        Button {
            isRecording.toggle()
        } label: {
            labelContent()
        }
        .buttonStyle(.pushDown)
        .frame(width: CGSize.systemSize.recordButton.width, height: CGSize.systemSize.recordButton.height)
        .sensoryFeedback(.start, trigger: isPressed)
    }
}

struct RecordButtonView: View {

    @Binding var isRecording: Bool
    @State private var isPressed: Bool = false

    var stopRoundedRectShape: RoundedRectangle {
        .init(cornerRadius:  isRecording ? 7 : 99, style: .continuous)
    }

    var fraction: CGFloat {
        .init(.recordWidth / 1.5)
    }

    @ViewBuilder
    func squareStopShape() -> some View {
        stopRoundedRectShape
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [.recordingRed.exposureAdjust(-20), .clear]),
                    center: .bottomTrailing,
                    startRadius: 30,
                    endRadius: 30))

            .frame(
                width: .recordWidth,
                height: .recordHeight
            )
            .glassEffect(.regular.tint(Color(.recordingRed)), in: stopRoundedRectShape)
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [.white.opacity( isRecording ? 0.7 : 0.9), .clear]),
                    center: .bottomTrailing,
                    startRadius: fraction,
                    endRadius: fraction / 2
                ), in: stopRoundedRectShape)
    }


    @ViewBuilder
    func buttonShape() -> some View {
        ZStack {
            Circle()
               // .fill(.fill.materialActiveAppearance(.matchWindow))
                .frame(
                    width: .recordWidth * 1.3,
                    height: .recordHeight * 1.3
                )
                .glassEffect(.clear, in: .circle)

            _IconContent(isRecording: $isRecording)
                .scaleEffect(isRecording ? 0.7 : 1.0)// delegates to shapes below
        }
    }


    var body: some View {

        Button {
            withAnimation(.bouncy) {
                isRecording.toggle()
            }
        } label: {
            Label {
                Text("Record")
            } icon: {
                buttonShape()
            }
            .labelIconToTitleSpacing(8)
            .padding(.vertical, 3)
            .padding(.trailing, 4)
        }
        .buttonBorderShape(.capsule)
        .buttonStyle(RecordButtonStyle())
        .labelStyle(IconOnlyPressTransformLabelStyle())
    }
}

private struct _IconContent: View {
    @Environment(\._recordButtonIsPressed) private var isPressed
    @Binding var isRecording: Bool
    var body: some View {
        Group {

                RecordButtonView(isRecording: $isRecording)
                    .squareStopShape()

        }
        .opacity(isPressed ? 0.95 : 1)
    }
}

extension RecordButtonView {



    struct RecordButtonShape: ViewModifier {

        func body(content: Content) -> some View {
            ZStack {
                content
                    .opacity(0.0)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            }
        }

    }

}

struct IconOnlyPressTransformLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
                .accessibilityIdentifier("recordButton.icon")
            configuration.title
        }
    }
}

struct RecordButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .labelStyle(IconOnlyPressTransformLabelStyle())
            .buttonStyle(.pushDown)
            .modifier(IconPressEffect(isPressed: configuration.isPressed))

    }
}

private struct IconPressEffect: ViewModifier {
    let isPressed: Bool
    func body(content: Content) -> some View {
        content
            .environment(\._recordButtonIsPressed, isPressed)
    }
}

private struct _RecordButtonIsPressedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
private extension EnvironmentValues {
    var _recordButtonIsPressed: Bool {
        get { self[_RecordButtonIsPressedKey.self] }
        set { self[_RecordButtonIsPressedKey.self] = newValue }
    }
}

#Preview("Metallic Record Button") {
    @Previewable @State var isRecording: Bool = false

    LazyVStack {
        RecordButtonView(isRecording: $isRecording)
            .scaleEffect(2)
    }
    .padding()
    .frame(width: 600, height: 600)
}

#Preview("Metallic Neumorphic Record Button")  {
    @Previewable @State var isRecording: Bool = false

    ZStack {
        RoundedRectangle(cornerRadius: 10)

            .reverseMask {
                Circle()
                    .frame(width: CGSize.systemSize.recordButton.width, height: CGSize.systemSize.recordButton.height)
                    .scaleEffect(1.5)
            }
        RecordButton(isRecording: $isRecording)
    }
    .frame(width: 150, height: 150)
    .glassEffect(.clear)
    .padding()


}

