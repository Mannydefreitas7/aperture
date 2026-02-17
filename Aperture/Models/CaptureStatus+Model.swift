//
//  CaptureStatus+Model.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/18/26.
//
import AVFoundation

enum CaptureStatus: Equatable {
    case idle
    case configuring
    case running
    case stopped
    case interrupted(reason: AVError.Code)
    case unauthorized
    case failed(message: String)
}
