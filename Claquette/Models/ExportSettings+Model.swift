import Foundation

struct ExportSettings {
    var format: ExportFormat
    var quality: ExportQuality
    var codec: VideoCodec
    var resolution: ExportResolution
    var frameRate: Int
    var loopCount: Int
    var optimizeForWeb: Bool

    static var defaultVideo: ExportSettings {
        ExportSettings(
            format: .video,
            quality: .high,
            codec: .h264,
            resolution: .original,
            frameRate: 30,
            loopCount: 0,
            optimizeForWeb: false
        )
    }

    static var defaultGIF: ExportSettings {
        ExportSettings(
            format: .gif,
            quality: .medium,
            codec: .h264,
            resolution: .original,
            frameRate: 15,
            loopCount: 0,
            optimizeForWeb: true
        )
    }
}
