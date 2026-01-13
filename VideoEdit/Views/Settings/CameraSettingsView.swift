import SwiftUI
import AVFoundation

struct CameraSettingsView: View {
    @ObservedObject var cameraManager: CameraPreviewViewModel
    @AppStorage("cameraPosition") var position: CameraPosition = .bottomRight
    @AppStorage("cameraSize") var size: CameraSize = .medium
    @AppStorage("cameraShape") var shape: CameraShape = .circle
    @AppStorage("cameraPreviewVisible") var isVisible: Bool = true

    @StateObject var cameraViewModel: CameraPreviewViewModel = .init()

    var body: some View {
        Form {

            Section {

                VideoOutputView(
                    captureSession: $cameraViewModel.session,
                    isMirror: $cameraManager.isMirrored
                )

                if !cameraViewModel.isLoading || isVisible {


                    ProgressView()
                        .progressViewStyle(.circular)

                } else {
                    Picker("Camera", selection: $cameraManager.selectedCamera) {
                        ForEach(cameraManager.availableCameras, id: \.id) { camera in
                            Text(camera.name)
                                .tag(camera.id)
                        }
                    }

                }

            } header: {
                Text("Camera")
                    .foregroundStyle(.foreground.secondary)
            }


            if isVisible {
                Section("Appearance") {
                    Picker("Position", selection: $position) {
                        ForEach(CameraPosition.allCases, id: \.self) { pos in
                            Label(pos.rawValue, systemImage: pos.systemImage).tag(pos)
                        }
                    }

                    Picker("Size", selection: $size) {
                        ForEach(CameraSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }

                    Picker("Shape", selection: $shape) {
                        ForEach(CameraShape.allCases, id: \.self) { shape in
                            Text(shape.rawValue).tag(shape)
                        }
                    }
                }
            }
        }
        .formStyle(.automatic)
        .controlSize(.large)
       // .task(cameraViewModel.loadCameras)
    }
}

#Preview {

    @Previewable @StateObject var cameraManager: CameraPreviewViewModel = .init()

    CameraSettingsView(cameraManager: cameraManager)
        .padding()
        .frame(width: 600, height: 400)

}
