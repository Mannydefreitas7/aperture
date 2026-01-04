//
//  NewFileButton.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-03.
//
import SwiftUI
import WelcomeWindow

struct NewFileButton: View {

    var dismissWindow: () -> Void

    var body: some View {
        WelcomeButton(
            iconName: "plus.square",
            title: "Create New File...",
            action: {
                //
                dismissWindow()
            }
        )
    }
}
