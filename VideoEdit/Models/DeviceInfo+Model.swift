//
//  DeviceInfo+Model.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/18/26.
//

import AVFoundation

struct DeviceInfo: Identifiable, Equatable {
    enum Kind: Equatable { case video, audio }

    let id: String            // AVCaptureDevice.uniqueID
    let kind: Kind
    let name: String          // localizedName
    let position: AVCaptureDevice.Position
}
