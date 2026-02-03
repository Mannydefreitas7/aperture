//
//  Capture+Window.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI

struct CaptureWindow: Scene {

    @EnvironmentObject var appState: AppState

    var body: some Scene {
        WindowGroup(.sceneIdentifier, id: .window(.recording)) {
            CaptureView()
                .frame(minWidth: .minWindowWidth, minHeight: .minWindowHeight)
                .isHovering()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: .defaultRecordWidth, height: .defaultRecordHeight)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)
        .commands {
            // General Commands
            GeneralCommand(appState: appState)
            // Video Commands
            VideoCommand(appState: appState)
        }
    }
}
