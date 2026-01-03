import SwiftUI
import AVFoundation
//import ScreenCaptureKit

@main
struct ClaquetteApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {

        Window(Text("Welcome to Claquette!"), id: Constants.Windows.main.rawValue) {
            Onboarding()
                .frame(width: 600, height: 800)
                .hideWindowControls()
                .centerWindow()
        }
        .windowResizability(.contentSize)



        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Video...") {
                    appState.openFile()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Divider()
                
                Button("New Screen Recording") {
                    appState.showRecordingSheet = true
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
            
            CommandMenu("Video") {
                Button("Crop") {
                    appState.currentTool = .crop
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .disabled(appState.videoURL == nil)
                
                Button("Trim") {
                    appState.currentTool = .trim
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
                .disabled(appState.videoURL == nil)
                
                Divider()
                
                Button("Export as GIF...") {
                    appState.showExportSheet = true
                    appState.exportFormat = .gif
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .disabled(appState.videoURL == nil)
                
                Button("Export as Movie...") {
                    appState.showExportSheet = true
                    appState.exportFormat = .movie
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(appState.videoURL == nil)
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var videoURL: URL?
    @Published var currentTool: EditingTool = .none
    @Published var showRecordingSheet = false
    @Published var showExportSheet = false
    @Published var exportFormat: ExportFormat = .movie
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    
    // Crop settings
    @Published var cropRect: CGRect = .zero
    @Published var isCropping = false
    
    // Trim settings
    @Published var trimStart: Double = 0
    @Published var trimEnd: Double = 1
    
    // Recording settings
    @Published var recordMicrophone = true
    @Published var recordSystemAudio = false
    @Published var showCameraOverlay = false
    @Published var visualizeClicks = true
    @Published var recordingQuality: RecordingQuality = .high
    
    // GIF settings
    @Published var gifFrameRate: Int = 15
    @Published var gifLoopCount: Int = 0 // 0 = infinite
    @Published var gifScale: Double = 1.0
    @Published var gifOptimize = true
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.movie, .video, .mpeg4Movie, .quickTimeMovie, .gif]
        
        if panel.runModal() == .OK {
            videoURL = panel.url
            currentTool = .none
            cropRect = .zero
            trimStart = 0
            trimEnd = 1
        }
    }
    
    func saveFile(completion: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = exportFormat == .gif ? [.gif] : [.mpeg4Movie]
        panel.nameFieldStringValue = exportFormat == .gif ? "export.gif" : "export.mp4"
        
        if panel.runModal() == .OK {
            completion(panel.url)
        } else {
            completion(nil)
        }
    }
}
