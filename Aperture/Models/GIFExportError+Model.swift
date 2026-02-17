import Foundation

enum GIFExportError: LocalizedError {
    case noVideoTrack
    case noFrames
    case destinationCreationFailed
    case finalizationFailed

    var errorDescription: String? {
        switch self {
        case .noVideoTrack: return "No video track found"
        case .noFrames: return "No frames to export"
        case .destinationCreationFailed: return "Failed to create export destination"
        case .finalizationFailed: return "Failed to finalize export"
        }
    }
}
