import SwiftUI
import AVFoundation

struct CameraSettingsView: View {
   // @ObservedObject var cameraManager: CameraPreviewViewModel
    @AppStorage("cameraPosition") var position: CameraPosition = .bottomRight
    @AppStorage("cameraSize") var size: CameraSize = .medium
    @AppStorage("cameraShape") var shape: CameraShape = .circle
    @AppStorage("cameraPreviewVisible") var isVisible: Bool = true

   // @StateObject var cameraViewModel: CameraPreviewViewModel = .init()

    var body: some View {
        Form {




        }
        .formStyle(.automatic)
        .controlSize(.large)
       
    }
}
