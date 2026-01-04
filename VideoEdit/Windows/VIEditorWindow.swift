//
//  EditorWindow.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI

struct VIEditorWindow: Scene {

    @StateObject var appState: AppState = AppState()
    @StateObject var viewModel = ViewModel()

    var body: some Scene {
        Window("", id: Constants.SceneID.editor.rawValue) {
            VICameraCaptureView()

                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
    }
}

extension VIEditorWindow {

    class ViewModel: ObservableObject {

        @Published var isVisible: Bool = true
        @Published var position: CameraPosition = .topLeft
        @Published var size: CameraSize = .small
        @Published var shape: CameraShape = .circle


    }

}
