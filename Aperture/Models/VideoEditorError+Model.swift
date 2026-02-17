import Foundation

enum VideoEditorError: LocalizedError {
    case noVideoTrack
    case exportSessionCreationFailed
    case exportFailed
    case compositionFailed

    var errorDescription: String? {
        switch self {
        case .noVideoTrack: return "No video track found"
        case .exportSessionCreationFailed: return "Failed to create export session"
        case .exportFailed: return "Export failed"
        case .compositionFailed: return "Failed to create video composition"
        }
    }
}
