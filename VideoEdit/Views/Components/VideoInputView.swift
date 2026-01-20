//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import SFSafeSymbols

struct VideoInputView: View {

    @Binding var isOn: Bool
    var label: String
    var action: () -> Void

    var body: some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $isOn) {
                Image(systemSymbol: .webCamera)
                    .font(.title2)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: isOn)

            if isOn {
                Button {
                    action()
                } label: {
                    Text(label)
                }
                .buttonStyle(.accessoryBar)
            }
        }
    }
}

extension VideoInputView {

    @Observable class ViewModel {

        var isOn: Bool = false
        var isPresented: Bool = false

    }

    enum UIString: String {
        case label = "S3 Camera HD"
        case icon = "web.camera"
    }
}

#Preview {
    VideoInputView(isOn: .constant(true), label: "Test") {
        //
    }
}
