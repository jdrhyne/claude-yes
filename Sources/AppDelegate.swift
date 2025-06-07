import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let automationEngine = AutomationEngine()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Claude Yes: Starting up...")
        setupMenuBar()
        setupPopover()
        checkAccessibilityPermissions()
        
        // Hide dock icon since this is a menu bar app
        NSApp.setActivationPolicy(.accessory)
        print("Claude Yes: Menu bar app ready!")
    }
    
    private func checkAccessibilityPermissions() {
        let terminalService = TerminalService()
        
        if !terminalService.checkAccessibilityPermissions() {
            DispatchQueue.main.async {
                self.showPermissionsAlert()
            }
        }
    }
    
    private func showPermissionsAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = """
        Claude Yes needs accessibility permissions to read terminal content and send keystrokes.
        
        To grant permissions:
        1. Open System Settings
        2. Go to Privacy & Security → Accessibility
        3. Add Claude Yes to the list of allowed apps
        
        The app will not function without these permissions.
        """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checkmark.circle", accessibilityDescription: "Claude Yes")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView(automationEngine: automationEngine)
        )
    }
    
    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}