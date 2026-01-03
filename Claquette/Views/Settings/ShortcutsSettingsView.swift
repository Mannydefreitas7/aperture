import SwiftUI

struct ShortcutsSettingsView: View {
    var body: some View {
        Form {
            Section("Recording") {
                ShortcutRow(action: "Start/Stop Recording", shortcut: "⌘⇧R")
                ShortcutRow(action: "Pause/Resume Recording", shortcut: "⌘⇧P")
                ShortcutRow(action: "Cancel Recording", shortcut: "⎋")
            }

            Section("Editing") {
                ShortcutRow(action: "Crop Tool", shortcut: "⌘⇧C")
                ShortcutRow(action: "Trim Tool", shortcut: "⌘⇧T")
                ShortcutRow(action: "Reset Edit", shortcut: "⌘R")
            }

            Section("Playback") {
                ShortcutRow(action: "Play/Pause", shortcut: "Space")
                ShortcutRow(action: "Jump to Start", shortcut: "↖")
                ShortcutRow(action: "Jump to End", shortcut: "↘")
            }

            Section("Export") {
                ShortcutRow(action: "Export Video", shortcut: "⌘E")
                ShortcutRow(action: "Quick Export GIF", shortcut: "⌘⇧G")
            }
        }
        .formStyle(.grouped)
    }
}
