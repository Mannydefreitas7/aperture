//
//  ScreenRecorderView.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-01.
//

import SwiftUI
import ScreenCaptureKit

@MainActor
class ScreenRecorderViewModel: ObservableObject {
    @Published var permissionStatus: PermissionStatus = .unknown
    @Published var availableDisplays: [SCDisplay] = []
    @Published var availableWindows: [SCWindow] = []
    

    enum PermissionStatus {
        case unknown
        case granted
        case denied
    }

    func checkAndRequestPermission() async {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(
                false,
                onScreenWindowsOnly: true
            )

            availableDisplays = content.displays
            availableWindows = content.windows
            permissionStatus = .granted

        } catch let error as NSError {
            if error.code == -3801 { // SCStreamErrorUserDeclined
                permissionStatus = .denied
            } else {
                permissionStatus = .denied
            }
            print("Permission error: \(error)")
        }
    }

    func openSystemPreferences() {
        guard let url = URL(string: Constants.screen_capture_security_key) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}

struct TContentView: View {
    @StateObject private var recorder = ScreenRecorderViewModel()

    var body: some View {
        VStack(spacing: 20) {
            switch recorder.permissionStatus {
                case .unknown:
                    ProgressView("Checking permission...")

                case .granted:
                    VStack {
                        Label("Permission Granted", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)

                        Text("Available displays: \(recorder.availableDisplays.count)")
                        Text("Available windows: \(recorder.availableWindows.count)")
                    }

                case .denied:
                    VStack(spacing: 16) {
                        Label("Permission Required", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)

                        Text("Please enable screen recording in System Settings.")
                            .foregroundColor(.secondary)

                        HStack {
                            Button("Open System Settings") {
                                recorder.openSystemPreferences()
                            }

                            Button("Check Again") {
                                Task {
                                    await recorder.checkAndRequestPermission()
                                }
                            }
                        }
                    }
            }
        }
        .padding(40)
        .task {
            await recorder.checkAndRequestPermission()
        }
    }
}
