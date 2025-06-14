import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    private var overlayWindows: [NSWindow] = []
    private var isDarkModeEnabled = false
    private var dimAmount: CGFloat = 0.5
    private var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadSettings()
        setupStatusBar()
        hideFromDock()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func loadSettings() {
        let storedDimAmount = UserDefaults.standard.double(forKey: "dimAmount")
        if storedDimAmount > 0 {
            dimAmount = CGFloat(storedDimAmount)
        }
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
        
        let dimmerItem = NSMenuItem(title: "Adjust Dimming...", action: #selector(showDimmerPopover), keyEquivalent: "")
        dimmerItem.target = self
        menu.addItem(dimmerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: "About Curtains", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        let quitItem = NSMenuItem(title: "Quit Curtains", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func showDimmerPopover() {
        guard let button = statusItem?.button else { return }
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 200, height: 60)
        popover.behavior = .transient
        popover.contentViewController = createSliderViewController()
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        self.popover = popover
    }
    
    private func createSliderViewController() -> NSViewController {
        let viewController = NSViewController()
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 60))
        
        let slider = NSSlider(frame: NSRect(x: 20, y: 20, width: 160, height: 20))
        slider.minValue = 0.1
        slider.maxValue = 0.9
        slider.doubleValue = Double(dimAmount)
        slider.target = self
        slider.action = #selector(sliderChanged(_:))
        
        view.addSubview(slider)
        viewController.view = view
        
        return viewController
    }
    
    @objc private func sliderChanged(_ sender: NSSlider) {
        dimAmount = CGFloat(sender.doubleValue)
        UserDefaults.standard.set(dimAmount, forKey: "dimAmount")
        if isDarkModeEnabled {
            updateOverlayOpacity()
        }
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
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Curtains"
        alert.informativeText = "Curtains is a screen dimming utility by Bradly Feeley."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Visit Website")
        alert.addButton(withTitle: "OK")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "https://bradlyfeeley.com") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func createOverlay() {
        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            window.level = NSWindow.Level.screenSaver
            window.backgroundColor = NSColor.black.withAlphaComponent(dimAmount)
            window.isOpaque = false
            window.hasShadow = false
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            window.orderFront(nil)
            overlayWindows.append(window)
        }
    }
    
    private func updateOverlayOpacity() {
        for window in overlayWindows {
            window.backgroundColor = NSColor.black.withAlphaComponent(dimAmount)
        }
    }
    
    private func removeOverlay() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
    }
}
