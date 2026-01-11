//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI

struct AudioInputView: View {

    var action: () -> Void = { }

    var body: some View {
        Button {
            action()
        } label: {
            Label(UIString.label.rawValue, systemImage: UIString.icon.rawValue)
                .font(.title2)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.glassToolBar)
    }
}

extension AudioInputView {
    enum UIString: String {
        case label = "On"
        case icon = "microphone"
    }
}

#Preview {
    AudioInputView()
}
