//
//  CaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//

import SwiftUI

struct CaptureView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        CameraCaptureView(viewModel: appState.captureViewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .windowResizeAnchor(.bottomLeading)
            .ignoresSafeArea(.all)
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            .environmentObject(appState)
            .onDisappear {
                Task {
                    await appState.captureViewModel.onDisappear()
                }
            }
            .task {
                await appState.captureViewModel.onAppear()
            }
            .windowDismissBehavior(.enabled)
    }
}

#Preview {
    CaptureView()
}
