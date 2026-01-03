import SwiftUI

//
//  MouseVisualizerSettingsView.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-01.
//

    // MARK: - Settings View

    struct MouseVisualizerSettingsView: View {
        @ObservedObject var clickVisualizer: MouseClickVisualizer
        @ObservedObject var cursorVisualizer: MouseCursorVisualizer

        var body: some View {
            Form {
                Section("Click Visualization") {
                    Toggle("Show click highlights", isOn: $clickVisualizer.isEnabled)

                    if clickVisualizer.isEnabled {
                        ColorPicker("Highlight color", selection: $clickVisualizer.highlightColor)

                        Slider(value: $clickVisualizer.highlightSize, in: 20...100) {
                            Text("Size: \(Int(clickVisualizer.highlightSize))")
                        }

                        Toggle("Show ripple effect", isOn: $clickVisualizer.showRipple)
                    }
                }

                Section("Cursor Visualization") {
                    Toggle("Highlight cursor", isOn: $cursorVisualizer.cursorHighlight)

                    if cursorVisualizer.cursorHighlight {
                        ColorPicker("Cursor highlight color", selection: $cursorVisualizer.highlightColor)
                    }

                    Toggle("Show cursor trail", isOn: $cursorVisualizer.showTrail)

                    if cursorVisualizer.showTrail {
                        Stepper("Trail length: \(cursorVisualizer.trailLength)", value: $cursorVisualizer.trailLength, in: 5...30)
                    }
                }
            }
            .formStyle(.grouped)
        }
    }

    // MARK: - Preview

    #Preview {
        MouseVisualizerSettingsView(
            clickVisualizer: MouseClickVisualizer.shared,
            cursorVisualizer: MouseCursorVisualizer.shared
        )
        .frame(width: 400, height: 400)
    }
