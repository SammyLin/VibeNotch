import SwiftUI
import AppKit

@main
struct NotchAgentApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Use Settings scene as a placeholder — real UI is in the NSPanel
        Settings {
            EmptyView()
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: NSPanel?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon — this is a menu bar / overlay app
        NSApp.setActivationPolicy(.accessory)

        setupMenuBarItem()
        setupNotchPanel()
    }

    // MARK: - Menu Bar

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.grid.3x3.fill", accessibilityDescription: "NotchAgent")
            button.action = #selector(togglePanel)
            button.target = self
        }
    }

    // MARK: - Notch Panel

    private func setupNotchPanel() {
        guard let screen = NSScreen.main else { return }

        let hasNotch = screen.safeAreaInsets.top > 0
        let panelWidth: CGFloat = 300
        let panelHeight: CGFloat = 32

        // Position: centered at top of screen, in the notch area
        let screenFrame = screen.frame
        let x = screenFrame.midX - panelWidth / 2
        let y: CGFloat
        if hasNotch {
            // Place right below the menu bar / in the notch area
            y = screenFrame.maxY - screen.safeAreaInsets.top
        } else {
            // Fallback: top-center floating bar
            y = screenFrame.maxY - panelHeight - 4
        }

        let contentRect = NSRect(x: x, y: y, width: panelWidth, height: panelHeight)

        let panel = NSPanel(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = false
        panel.animationBehavior = .utilityWindow

        let hostingView = NSHostingView(rootView: NotchPanelView())
        hostingView.frame = panel.contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        panel.contentView?.addSubview(hostingView)

        panel.orderFrontRegardless()
        self.panel = panel

        print("[NotchAgent] Panel positioned at (\(x), \(y)), notch detected: \(hasNotch)")
    }

    @objc private func togglePanel() {
        if let panel = panel {
            if panel.isVisible {
                panel.orderOut(nil)
            } else {
                panel.orderFrontRegardless()
            }
        }
    }
}
