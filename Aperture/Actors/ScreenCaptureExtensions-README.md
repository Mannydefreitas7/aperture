# CaptureEngine Screen Capture Extensions

This extension adds comprehensive screen, window, and external camera recording capabilities to the `CaptureEngine` actor using ScreenCaptureKit and AVFoundation.

## Files Created

### 1. `CaptureEngine+ScreenCapture.swift`
The main extension that provides:
- **Permission Management**: Check and request screen recording permissions
- **Content Discovery**: Get available displays, windows, and external cameras
- **Capture Session Management**: Start/stop screen and window capture
- **Sample Buffer Streaming**: Access real-time capture frames via AsyncStream

### 2. `CaptureEngine+ScreenRecording.swift`
Recording functionality that provides:
- **File Recording**: Record screen/window capture directly to video files
- **Pause/Resume**: Control recording state
- **Customizable Settings**: Configure video/audio codecs, bitrates, etc.
- **Multiple Audio Sources**: Support for system audio and microphone

### 3. `CaptureEngine+ScreenCapture+Usage.swift`
Comprehensive usage examples demonstrating:
- Permission handling
- Display and window capture
- External camera integration
- File recording workflows
- SwiftUI integration patterns

## Key Features

### 📹 Multiple Capture Sources
```swift
enum ScreenCaptureSource {
    case display(SCDisplay)      // Capture entire display
    case window(SCWindow)         // Capture specific window
    case externalCamera(AVCaptureDevice)  // Use external camera
}
```

### ⚙️ Flexible Configuration
```swift
struct ScreenCaptureConfiguration {
    var source: ScreenCaptureSource
    var width: Int
    var height: Int
    var frameRate: Int
    var showsCursor: Bool
    var capturesAudio: Bool
    var scaleFactor: Double
}
```

### 💾 Recording Settings
```swift
struct ScreenRecordingSettings {
    var outputURL: URL
    var videoCodec: AVVideoCodecType
    var audioBitRate: Int
    var videoBitRate: Int
    var includeSystemAudio: Bool
    var includeMicrophoneAudio: Bool
}
```

## Usage Quick Start

### 1. Check Permission
```swift
let engine = CaptureEngine()
let hasPermission = await engine.checkScreenRecordingPermission()

if !hasPermission {
    let granted = try await engine.requestScreenRecordingPermission()
}
```

### 2. Get Available Content
```swift
let content = try await engine.getAvailableScreenCaptureContent()
let displays = content.displays
let windows = content.filteredWindows
let cameras = await engine.getAvailableExternalCameras()
```

### 3. Start Capture
```swift
let config = ScreenCaptureConfiguration(
    source: .display(mainDisplay),
    frameRate: 30,
    showsCursor: true,
    capturesAudio: true
)

try await engine.startScreenCapture(with: config)

// Process frames in real-time
let stream = engine.makeScreenCaptureSampleBufferStream()
for await sampleBuffer in stream {
    // Process each frame
}
```

### 4. Record to File
```swift
let captureConfig = ScreenCaptureConfiguration(
    source: .display(mainDisplay),
    frameRate: 30,
    showsCursor: true,
    capturesAudio: true
)

let recordingSettings = ScreenRecordingSettings(
    videoCodec: .h264,
    includeSystemAudio: true
)

// Start recording
let outputURL = try await engine.startScreenRecording(
    captureConfig: captureConfig,
    recordingSettings: recordingSettings
)

// Stop and get result
let recording = try await engine.stopScreenRecording()
print("Saved to: \(recording.url)")
print("Duration: \(recording.duration)s")
```

## Platform Support

- ✅ **macOS only** (uses ScreenCaptureKit which is macOS-exclusive)
- All code is wrapped in `#if os(macOS)` compiler directives
- External camera support works across AVFoundation-supported devices

## Architecture

### Actor-Based Design
The extensions maintain the actor-based architecture of the original `CaptureEngine`:
- Thread-safe access to capture state
- Uses custom executor (`UnownedSerialExecutor`) for serial queue execution
- Async/await patterns throughout

### State Management
Uses dedicated state actors to manage:
- `ScreenCaptureState`: Manages active capture sessions and streams
- `ScreenRecordingState`: Manages recording state and asset writers

### Integration
The extensions seamlessly integrate with existing `CaptureEngine` functionality:
- Uses the same session queue
- Compatible with existing photo/video capture
- Shares logging infrastructure
- Can switch between regular camera and external camera capture

## Error Handling

Comprehensive error types:
```swift
enum ScreenCaptureError: Error {
    case permissionDenied
    case noDisplaySelected
    case noWindowSelected
    case streamConfigurationFailed
    case alreadyCapturing
    case notCapturing
}

enum ScreenRecordingError: Error {
    case noOutputURL
    case writerSetupFailed
    case alreadyRecording
    case notRecording
    case writerNotReady
}
```

## Best Practices

1. **Always check permissions** before attempting capture
2. **Clean up streams** when done to avoid memory leaks
3. **Use appropriate frame rates** for your use case (30fps for general, 60fps for smooth playback)
4. **Consider scale factor** for high-DPI displays (default 1.0, use 2.0 for Retina)
5. **Monitor recording duration** for user feedback
6. **Handle errors gracefully** with proper user messaging

## SwiftUI Integration

The extension works seamlessly with SwiftUI using `@MainActor` view models and async/await patterns. See the complete example in the usage file.

## Performance Considerations

- Sample buffers are processed on background queues
- Asset writer uses real-time expectations
- Memory-efficient streaming without buffering entire recordings
- Configurable quality settings to balance performance and file size

## Future Enhancements

Potential additions:
- Multiple simultaneous capture sources
- Live composition (PiP, overlays)
- Hardware encoding options
- Custom filters and effects
- Thumbnail generation
- Progress callbacks

## Dependencies

- ScreenCaptureKit (macOS 12.3+)
- AVFoundation
- CoreMedia
- Foundation

---

**Note**: These extensions follow the same design patterns and conventions as the existing `CaptureEngine` implementation, ensuring consistency and maintainability.
