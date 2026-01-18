//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import SFSafeSymbols

struct VideoInputView: View {

    var label: String
    var action: () -> Void
    @State private var isPresented: Bool = false

    var body: some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $isPresented) {
                Image(systemSymbol: .webCamera)
                    .font(.title2)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: isPresented)

            if isPresented {
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
    enum UIString: String {
        case label = "S3 Camera HD"
        case icon = "web.camera"
    }
}

#Preview {
    VideoInputView(label: "Test") {
        //
    }
}
