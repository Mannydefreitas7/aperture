//
//  PushDownButtonStyle.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-07.
//
import SwiftUI
import Pow

struct PushDownEffect: ViewModifier {

    @State private var isPressed: Bool = false

    public func body(content: Content) -> some View {
        content
            .opacity(isPressed ? 0.75 : 1)
            .conditionalEffect(
                .pushDown,
                condition: isPressed
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged({ _ in isPressed = true })
                    .onEnded({ _ in isPressed = false })
            )
    }
}
