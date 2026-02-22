//
//  AudioInput+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-07.
//

import SwiftUI
import AVFoundation
import Combine

extension AudioInputView {

    @MainActor
    @Observable final class ViewModel {

       public var deviceId: AVDevice.ID = .defaultAudioId
       public var showSettings: Bool = false
       public var selectedDevice: AVDevice = .defaultDevice(.audio)
    }
}
