//
//  VideoInput+View.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//

import SwiftUI
import SFSafeSymbols
import AVFoundation
import AVKit
import AppState

struct VideoInputView: View {

    var controlGroup: Namespace.ID
    @Binding var device: AVDevice
        /// View model
    @EnvironmentObject var viewModel: RecordingToolbar.ViewModel

    var body: some View {
        Group {
            if device.showSettings {
                ToolBarOptions()
                    .frame(height: .popoverWidth)
                    .clipShape(device.shape)
                    .task {
                        await viewModel.videoInputViewModel.start()
                    }
            } else {
                ToolButton()
                     .frame(height: .minHeight)
                    .padding(.horizontal, .small)
            }
        }
        .glassEffect(.regular, in: device.shape)
        .toolEffectUnion(
            id: device.isOn ? .video : .options,
            namespace: controlGroup
        )
        .onDisappear {
            Task {
                await viewModel.videoInputViewModel.stop()
            }
        }
        .task {
            // Starts the video input if its session
            // isn't running and device is on.
            if device.isOn {
                await viewModel.videoInputViewModel.initialize()
            }
        }

    }
}
