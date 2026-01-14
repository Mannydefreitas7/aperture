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
        WindowGroup("Editor", id: Constants.SceneID.editor.rawValue) {
            VICameraCaptureView()

                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .windowResizeAnchor(.bottomLeading)
                .ignoresSafeArea(.all)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .environmentObject(appState)
                
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentSize)
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
