import SwiftUI
import AVFoundation

struct CameraSettingsView: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var position: CameraPosition
    @Binding var size: CameraSize
    @Binding var shape: CameraShape
    @Binding var isVisible: Bool

    var body: some View {
        Form {
            Section("Camera") {
                Toggle("Show Camera Overlay", isOn: $isVisible)

                if isVisible {
                    Picker("Camera", selection: $cameraManager.selectedCamera) {
                        ForEach(cameraManager.availableCameras, id: \.id) { camera in
                            Text(camera.name)
                                .tag(camera.id)

                        }
                    }




                    Toggle("Mirror Camera", isOn: $cameraManager.isMirrored)
                }
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
        .formStyle(.grouped)
    }
}
