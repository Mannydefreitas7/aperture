import Foundation

enum RecordingError: LocalizedError {
    case alreadyRecording
    case notRecording
    case noDisplaySelected
    case noWindowSelected
    case noOutputURL
    case captureNotAuthorized

    var errorDescription: String? {
        switch self {
        case .alreadyRecording: return "Recording is already in progress"
        case .notRecording: return "No recording in progress"
        case .noDisplaySelected: return "No display selected"
        case .noWindowSelected: return "No window selected"
        case .noOutputURL: return "No output URL specified"
        case .captureNotAuthorized: return "Screen capture not authorized"
        }
    }
}
