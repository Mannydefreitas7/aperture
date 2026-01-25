//
//  EditorWindow.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import SwiftUIIntrospect

struct RecordingWindow: Scene {

    @EnvironmentObject var appState: AppState
    //@StateObject private var viewModel: ViewModel = .init()

    var body: some Scene {
        WindowGroup(Constants.Window.recording.rawValue, id: .window(.recording)) {
            CaptureView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentMinSize)
        .windowBackgroundDragBehavior(.enabled)
        .commands {
            // General Commands
            GeneralCommand(appState: appState)
            // Video Commands
            VideoCommand(appState: appState)
        }
    }
}

//extension RecordingWindow {
//
//    class ViewModel: ObservableObject {
//
//        @Published var isVisible: Bool = true
//        @Published var position: CameraPosition = .topLeft
//        @Published var size: CameraSize = .small
//        @Published var shape: CameraShape = .circle
//
//    }
//}
