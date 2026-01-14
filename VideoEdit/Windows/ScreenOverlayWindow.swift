//
//  ScreenOverlayWindow.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-14.
//

import SwiftUI
import ScreenCaptureKit
import SceneKit

struct TextView: View {
    @Environment(\.window) var backgroundStyle

    

    var body: some View {
        Button {
            //
        } label: {
            Text("Hello, World!")
                .padding()
                .background(.red)
        }



    }
}

struct ScreenOverlayWindow: Scene {
    var body: some Scene {




        Window("Screen Recording", id: Constants.Windows.main.rawValue) {
            TextView()

                .windowFullScreenBehavior(.enabled)
                .windowFullScreenBehavior(.enabled)
                .windowToolbarFullScreenVisibility(.onHover)
                .hideWindowControls()
                .presentationBackgroundInteraction(.enabled)
                .background(.clear, ignoresSafeAreaEdges: .all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        .windowIdealSize(.maximum)
        .defaultLaunchBehavior(.presented)

        UtilityWindow("", id: Constants.Windows.screenRecording.rawValue) {
            VStack {
                Text("TESTING").padding()
                    .background(.recordingRed)
            }
            .windowFullScreenBehavior(.enabled)
            .windowToolbarFullScreenVisibility(.onHover)
            .hideWindowControls()
            .presentationBackgroundInteraction(.enabled)
            .background(.clear, ignoresSafeAreaEdges: .all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .defaultPosition(.center)
        .persistentSystemOverlays(.visible)
        .restorationBehavior(.disabled)
        .windowBackgroundDragBehavior(.disabled)
        .windowManagerRole(.principal)
        .windowLevel(.floating)
        .windowStyle(.hiddenTitleBar)
    }
}

