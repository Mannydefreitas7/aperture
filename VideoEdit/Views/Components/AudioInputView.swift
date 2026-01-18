//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import SFSafeSymbols

struct AudioInputView: View {

    var label: String
    @Binding private var isOn: Bool

    @State private var isPresented: Bool = false
    @State private var volume: Double = 0

    var body: some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $isOn) {
                Image(systemSymbol: isOn ? .microphoneFill : .microphoneSlash)
                    .font(.title2)
            }
            .toggleStyle(.secondary)

            if isOn {
                Button {
                    withAnimation(.bouncy) {
                        isPresented.toggle()
                    }
                } label: {
                    Text(label)
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.glassToolBar)
            }
        }
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
