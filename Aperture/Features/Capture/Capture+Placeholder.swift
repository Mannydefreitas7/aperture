//
//  Capture+Placeholder.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-09.
//

import SwiftUI

struct CapturePlaceholder: View {

    @ObservedObject var viewModel: CaptureView.Store

    var body: some View {

        VStack {
            if viewModel.isConnecting && viewModel.hasConnectionTimeout {
                    // If there is a connection timeout,
                    // display, the manual refresh button
                Text("Could not connect. Try again.")
                Button("Refresh") {
                        //
                }

            } else if viewModel.isConnecting {
                    // If the device is connecting,
                    // display connection loader.
                DeviceConnectionLoading(viewModel.videoInput.selectedDevice)

            } else {
                    // If the state is empty, with no session running
                    // and no timeout errors, then display placeholder
                PlaceholderView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
