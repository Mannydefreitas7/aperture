import SwiftUI
import AVFoundation
import Combine

actor VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var showControls = true

    private var timeObserver: Any?

    func loadVideo(url: URL) {
        // Clean up existing player
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Get duration
        Task {
            let asset = AVURLAsset(url: url)
            if let dur = try? await asset.load(.duration) {
                duration = CMTimeGetSeconds(dur)
            }
        }

        // Add time observer
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = CMTimeGetSeconds(time)
        }

        // Observe playback status
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.isPlaying = false
            self?.player?.seek(to: .zero)
        }
    }

    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }

    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func stepForward() {
        let newTime = min(currentTime + (1.0/30.0), duration)
        seek(to: newTime)
    }

    func stepBackward() {
        let newTime = max(currentTime - (1.0/30.0), 0)
        seek(to: newTime)
    }

    deinit {
        if let observer = timeObserver { 
            player?.removeTimeObserver(observer)
        }
    }
}
