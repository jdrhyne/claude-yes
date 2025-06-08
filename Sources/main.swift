import Cocoa

print("Claude Yes: Launching application...")

// Create the application instance
let app = NSApplication.shared

// Create and set the delegate
let delegate = AppDelegate()
app.delegate = delegate

// Ensure app doesn't terminate after last window closes
app.setActivationPolicy(.accessory)

print("Claude Yes: Starting run loop...")

// Start the application
app.run()