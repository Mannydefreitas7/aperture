//
//  RecordButtonView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-06.
//

import SwiftUI

/// A metallic / shiny neumorphic record button with animated start/stop transition
/// and a press-down interaction.
struct RecordButtonView: View {

    @Binding var isRecording: Bool
    @State private var isPressed: Bool = false

    var body: some View {
        Toggle(isRecording ? "Recording..." : "Record", isOn: $isRecording)
            .toggleStyle(.recordButton)
            .sensoryFeedback(.start, trigger: isPressed)
    }
}


#Preview("Metallic Record Button") {
    @Previewable @State var isRecording: Bool = false

    LazyVStack {
        RecordButtonView(isRecording: $isRecording)
    }
    .padding()
    .frame(width: 600, height: 600)
}
