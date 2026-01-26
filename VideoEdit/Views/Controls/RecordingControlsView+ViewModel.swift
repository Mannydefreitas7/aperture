//
//  RecordingControlsView+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//

import SwiftUI
import Combine

extension RecordingControlsView {

    @MainActor
    final class ViewModel: ObservableObject {

        private var cancellables: Set<AnyCancellable> = []

        @Published var isRecording: Bool = false
        @Published var isTimerEnabled: Bool = false
        @Published var timerSelection: TimeInterval.Option = .threeSeconds
        @Published var isSettingsPresented: Bool = false
        @Published var showRecordButton: Bool = true

        @Published var microphone: DeviceInfo = .init(id: UUID().uuidString)

        @Published var camera: DeviceInfo = .init(id: UUID().uuidString)

        var spacing: CGFloat {
            isTimerEnabled || isRecording ? .small : .zero
        }

        var toggleAnimation: Bool {
            isRecording || isTimerEnabled
        }

        init() {
            $microphone
                .combineLatest($camera)
                .compactMap { $0.showSettings == false && $1.showSettings == false }
                .receive(on: RunLoop.main)
                .assign(to: \.showRecordButton, on: self)
                .store(in: &cancellables)
        }
    }
}
