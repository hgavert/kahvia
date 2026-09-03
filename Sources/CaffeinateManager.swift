import Foundation
import SwiftUI

// MARK: - Manager

@MainActor
final class CaffeinateManager: ObservableObject {

    // MARK: Published state

    /// Which caffeinate mode is currently active.
    @Published var activeState: AppState = .off {
        didSet {
            guard activeState != oldValue else { return }
            startCaffeinate(activeState)
        }
    }

    /// Whether a caffeinate process is running.
    @Published var isRunning = false

    // MARK: Private

    private var process: Process?
    private var generation = 0

    // MARK: Init

    // Always launches in `.off` — no state is restored across launches, so the
    // app never silently holds a sleep assertion you didn't ask for.
    init() {}

    // MARK: Process management

    private func startCaffeinate(_ state: AppState) {
        let myGeneration = generation
        generation += 1

        // Terminate any existing process first.
        process?.terminate()
        process = nil

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")

        switch state {
        case .off:
            return  // Nothing to start.
        case .on:
            // No flags — caffeinate's default is -i (idle sleep).
            proc.arguments = []
        case .display:
            proc.arguments = ["-d"]
        }

        // When this app exits, stop caffeinate too.
        proc.arguments! += ["-w", "\(ProcessInfo.processInfo.processIdentifier)"]

        proc.standardOutput = FileHandle.nullDevice
        proc.standardError = FileHandle.nullDevice
        proc.terminationHandler = { [weak self] proc in
            // Fires on a background thread; hop to main and ignore if superseded.
            DispatchQueue.main.async { [weak self] in
                guard let self, self.generation == myGeneration else { return }
                self.processDidExit(code: proc.terminationStatus)
            }
        }

        do {
            try proc.run()
            process = proc
            isRunning = true
        } catch {
            NSLog("caffeinate: failed to launch: \(error)")
            isRunning = false
            activeState = .off  // roll back inconsistent state
        }
    }

    private func processDidExit(code: Int32) {
        process = nil
        isRunning = false
        // Only auto-reset if nothing else has taken over in the meantime.
        if activeState != .off {
            activeState = .off
        }
    }

    // MARK: Computed values

    var statusText: String {
        switch activeState {
        case .off:
            return "Sleep allowed"
        case .on:
            return "Awake · idle blocked"
        case .display:
            return "Awake · display blocked"
        }
    }

    /// Base name of the bundled icon asset for the current state.
    private var iconResource: String {
        switch activeState {
        case .off:     return "cup-off"      // empty mug — sleep allowed
        case .on:      return "cup-on"       // filled mug + steam — caffeinated
        case .display: return "cup-display"  // mug in a screen — display kept on
        }
    }

    /// Template image shown in the menu bar. Loads the bundled vector PDF and
    /// falls back to an SF Symbol if the asset is missing.
    var menuBarIcon: NSImage {
        let image: NSImage
        if let url = Bundle.main.url(forResource: iconResource, withExtension: "pdf"),
           let pdf = NSImage(contentsOf: url) {
            image = pdf
        } else {
            image = NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: nil) ?? NSImage()
        }
        image.isTemplate = true               // let macOS tint it for light/dark
        image.size = NSSize(width: 18, height: 18)
        return image
    }

}

// MARK: - State enum

enum AppState: String, Codable, CaseIterable {
    case off
    case on
    case display
}
