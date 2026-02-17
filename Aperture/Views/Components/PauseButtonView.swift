//
//  PauseButtonView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI

struct PauseButtonView: View {

    var action: () -> Void = { }

    var body: some View {
        Button {
            action()
        } label: {
            Label(Constants.label, systemImage: Constants.icon)
                .font(.title3)
        }
        .buttonStyle(.glassToolBar)
        .buttonBorderShape(.capsule)
    }
}

extension Constants {

    static let label: String = "Pause"
    static let icon: String = "pause.circle"

}

#Preview {
    PauseButtonView()
}
