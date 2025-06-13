import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var overlayWindow: NSWindow?
    private var isDarkModeEnabled = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusBar()
        hideFromDock()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    private func hideFromDock() {
        NSApp.setActivationPolicy(.accessory)
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "curtains.open", accessibilityDescription: "Curtains")

        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Draw Curtains", action: #selector(toggleDarkMode), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Curtains", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        
        if isDarkModeEnabled {
            createOverlay()
            statusItem?.menu?.item(at: 0)?.title = "Open Curtains"
            statusItem?.button?.image = NSImage(systemSymbolName: "curtains.closed", accessibilityDescription: "Curtains Closed")
        } else {
            removeOverlay()
            statusItem?.menu?.item(at: 0)?.title = "Draw Curtains"
            statusItem?.button?.image = NSImage(systemSymbolName: "curtains.open", accessibilityDescription: "Curtains Open")
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func createOverlay() {
        guard let screen = NSScreen.main else { return }
        
        overlayWindow = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        overlayWindow?.level = NSWindow.Level.screenSaver
        overlayWindow?.backgroundColor = NSColor.black.withAlphaComponent(0.5)
        overlayWindow?.isOpaque = false
        overlayWindow?.hasShadow = false
        overlayWindow?.ignoresMouseEvents = true
        overlayWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        overlayWindow?.orderFront(nil)
    }
    
    private func removeOverlay() {
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
    }
}
