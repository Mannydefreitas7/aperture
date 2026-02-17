//
//  Button+ViewModifier.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-06.
//

import SwiftUI

struct HeartBeatModifier: ViewModifier {

    @State private var isBeating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isBeating ? 1.1 : 0.95)
            .onAppear {
                // Toggle once and let the repeating animation drive the in/out pulse.
                if isBeating == false {
                    withAnimation(
                        .easeInOut(duration: 1.5 / 2)
                        .repeatForever(autoreverses: true)
                    ) {
                        isBeating = true
                    }
                }
            }
    }
}
