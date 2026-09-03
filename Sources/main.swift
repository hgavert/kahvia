import SwiftUI
import AppKit

@main
struct KahviaApp: App {
    @StateObject private var manager = CaffeinateManager()

    var body: some Scene {
        MenuBarExtra {
            menuContent
        } label: {
            statusIcon
        }
        .menuBarExtraStyle(.menu)
    }

    // MARK: - Menu bar icon

    private var statusIcon: some View {
        Image(nsImage: manager.menuBarIcon)
            .renderingMode(.template)
    }

    // MARK: - Dropdown menu content

    @ViewBuilder
    private var menuContent: some View {
        Text(manager.statusText)
            .font(.subheadline)

        Divider()

        Picker("Mode", selection: $manager.activeState) {
            Text("Off — sleep allowed").tag(AppState.off)
            Text("On — keep awake").tag(AppState.on)
            Text("Display — keep display on (-d)").tag(AppState.display)
        }
        .pickerStyle(.inline)

        Divider()

        Button("Quit Kahvia") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
