import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

struct VideoDocument: FileDocument {
    static var readableContentTypes: [UTType] = [
        .movie,
        .mpeg4Movie,
        .quickTimeMovie,
        .avi,
        .mpeg,
        .gif
    ]

    static var writableContentTypes: [UTType] = [
        .movie,
        .mpeg4Movie,
        .quickTimeMovie,
        .gif
    ]

    var videoURL: URL?
    var videoData: Data?

    init(url: URL? = nil) {
        self.videoURL = url
        if let url = url {
            self.videoData = try? Data(contentsOf: url)
        }
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.videoData = data
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = videoData else {
            throw CocoaError(.fileWriteNoPermission)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
