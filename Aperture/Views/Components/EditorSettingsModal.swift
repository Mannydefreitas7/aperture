//
//  EditorSettingsModal.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-12.
//

import SwiftUI

struct EditorSettingsView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var cameraManager: CameraPreviewViewModel = .init()
    var body: some View {

            VStack {

                Text("Test")
                   

//                TabView {
//
//                    Tab("Video", systemImage: "web.camera") {
//                        CameraSettingsView(cameraManager: cameraManager)
//
//                    }
//
//                    Tab("Audio", systemImage: "microphone") {
//                        Text("Settings")
//
//                    }
//                }
//                .tabViewStyle(.tabBarOnly)
            }
            .padding()


//            .toolbar {
//
//                ToolbarItem {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Label("Close", systemImage: "xmark.circle.fill")
//                            .symbolRenderingMode(.hierarchical)
//                            .font(.title)
//                            .labelStyle(.iconOnly)
//                    }
//                    .buttonStyle(.borderless)
//                    .buttonBorderShape(.circle)
//                }
//
//            
//        }
    }
}

#Preview {

        EditorSettingsView()
        .frame(width: 600, height: 300)

}
