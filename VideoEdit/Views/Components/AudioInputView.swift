//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI

struct AudioInputView: View {
    @Binding var isOn: Bool

    @State var isPresented: Bool = false
    @State var volume: Double = 0
    var body: some View {
        HStack {
            Toggle(isOn: $isOn) {
                Label("Device name", systemImage: isOn ? "microphone.fill" : "microphone.slash")
                    .frame(minWidth: .medium)
            }
            .toggleStyle(.button)
            .buttonBorderShape(.circle)
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .animation(.bouncy, value: isOn)

            if isOn {
                Button {
                    isPresented.toggle()
                } label: {
                    Text("Device name")
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.accessoryBar)
            }
        }
        .controlSize(.extraLarge)
        .animation(.bouncy, value: isOn)
        .popover(isPresented: $isPresented) {
            VolumeHUD(volume: $volume)
                .frame(minWidth: .popoverWidth)
        }
    }
}

extension AudioInputView {
    enum UIString: String {
        case label = "On"
        case icon = "microphone"
    }
}

#Preview {

    @Previewable @State var isOn: Bool = false

    ZStack {
        AudioInputView(isOn: $isOn)
    }
    .frame(width: 600, height: 600)

}
