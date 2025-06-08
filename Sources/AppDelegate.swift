import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let automationEngine = AutomationEngine()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Claude Yes: Starting up...")
        
        // Set up as menu bar app FIRST
        NSApp.setActivationPolicy(.accessory)
        
        setupMenuBar()
        setupPopover()
        checkAccessibilityPermissions()
        
        // Skip notification permissions for now - requires app bundle
        
        print("Claude Yes: Menu bar app ready!")
        print("Claude Yes: Status item exists: \(statusItem != nil)")
        print("Claude Yes: Button exists: \(statusItem?.button != nil)")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false  // Keep app running even if windows are closed
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
            // Try a different icon that might be more visible
            if let image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Claude Yes") {
                button.image = image
                button.image?.isTemplate = true  // This makes it adapt to dark/light mode
                print("Claude Yes: Icon image set successfully")
            } else {
                // Fallback to text if image fails
                button.title = "CY"
                print("Claude Yes: Using text fallback for icon")
            }
            
            button.action = #selector(togglePopover)
            button.target = self
            
            print("Claude Yes: Button configured")
        } else {
            print("Claude Yes: ERROR - Could not create status bar button!")
        }
        
        print("Claude Yes: Menu bar icon created")
        print("Claude Yes: Status item visible: \(statusItem.isVisible)")
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
        guard let button = statusItem.button else {
            print("Claude Yes: ERROR - No button found")
            return
        }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            print("Claude Yes: Popover shown")
        }
    }
}