//
//  CaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI
import AVFoundation
import AppKit
import AVKit
import Combine

struct CaptureView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var state: CaptureView.ViewModel
    @State private var spacing: CGFloat = 8
    @State private var isTimerEnabled: Bool = false
    @State private var timerSelection: TimeInterval.Option = .threeSeconds
    @Environment(\.isHoveringWindow) var isHoveringWindow

    // User preferences to store/restore window parameters
    @Preference(\.aspectPreset) var aspectPreset
    @Preference(\.showSafeGuides) var showSafeGuides
    @Preference(\.showAspectMask) var showAspectMask
    @Preference(\.showPlatformSafe) var showPlatformSafe

    var body: some View {

        NavigationStack  {
            ZStack(alignment: .bottom) {
                if state.selectedVideoDevice.isOn {
                    // MARK: Video preview
                    VideoOutput()
                } else {
                    placeholderView()
                }

                // MARK: Crop mask for selected ratio
                MaskAspectRatioView()

                // MARK: Bottom bar content
                BottomBar()
                    .opacity(isHoveringWindow ? 1.0 : 0.0)

            }
            .environmentObject(state)
        }
        // Keep the window resizable but constrained to 16:9.
        .windowAspectRatio(AspectPreset.youtube.ratio)
    }
}
