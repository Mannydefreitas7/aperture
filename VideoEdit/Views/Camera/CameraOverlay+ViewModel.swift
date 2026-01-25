//
//  CameraOverlay+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//

import SwiftUI
import AVFoundation

extension CameraOverlayView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var isVisible: Bool = false
        @Published var position: CameraPosition = .topLeft
        @Published var size: CameraSize = .large
        @Published var shape: CameraShape = .circle

        @Published var isDragging = false
        @Published var dragOffset: CGSize = .zero

        @Published var isRecording: Bool = false
        @Published var isEditing: Bool = false
        @Published var isEditingCompleted: Bool = false
        @Published var isEditingFailed: Bool = false

        @Published var isPreviewing: Bool = false
        @Published var isPreviewingCompleted: Bool = false
        @Published var isPreviewingFailed: Bool = false
    }

}

