import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            // App icon
            Image(systemName: "film.stack.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            VStack(spacing: 4) {
                Text("Claquette")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("A powerful screen recording and video editing tool for macOS")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Divider()
                .padding(.vertical)

            VStack(spacing: 12) {
                Link("Visit Website", destination: URL(string: "https://claquette.app")!)
                Link("Privacy Policy", destination: URL(string: "https://claquette.app/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://claquette.app/terms")!)
                Link("Support", destination: URL(string: "mailto:support@claquette.app")!)
            }
            .font(.caption)

            Spacer()

            Text("© 2024 Claquette. All rights reserved.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 400)
    }
}
