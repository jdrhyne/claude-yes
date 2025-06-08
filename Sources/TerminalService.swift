import Foundation
import ApplicationServices
import Cocoa

class TerminalService {
    private let supportedTerminals = ["Terminal", "iTerm2", "iTerm"]
    
    func getTerminalOutput() -> String {
        guard let activeTerminal = getActiveTerminalApp() else {
            return ""
        }
        
        switch activeTerminal {
        case "Terminal":
            return getTerminalAppOutput()
        case "iTerm2", "iTerm":
            return getITermOutput()
        default:
            return ""
        }
    }
    
    func sendProceedCommand() {
        guard let activeTerminal = getActiveTerminalApp() else {
            return
        }
        
        // Send "1" followed by Enter
        sendKeystrokes("1\n", to: activeTerminal)
    }
    
    private func getActiveTerminalApp() -> String? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            print("Claude Yes: No frontmost application found")
            return nil
        }
        
        let appName = frontmostApp.localizedName ?? ""
        print("Claude Yes: Frontmost app is '\(appName)'")
        
        if supportedTerminals.contains(appName) {
            print("Claude Yes: Using terminal app: \(appName)")
            return appName
        } else {
            print("Claude Yes: App '\(appName)' is not a supported terminal")
            return nil
        }
    }
    
    private func getTerminalAppOutput() -> String {
        let script = """
        tell application "Terminal"
            if (count of windows) > 0 then
                get contents of selected tab of front window
            else
                return ""
            end if
        end tell
        """
        
        return executeAppleScript(script)
    }
    
    private func getITermOutput() -> String {
        let script = """
        tell application "iTerm"
            if (count of windows) > 0 then
                tell current session of current tab of current window
                    get contents
                end tell
            else
                return ""
            end if
        end tell
        """
        
        return executeAppleScript(script)
    }
    
    private func sendKeystrokes(_ text: String, to app: String) {
        let script: String
        
        switch app {
        case "Terminal":
            // For Terminal.app, we need to send actual keystrokes, not run a command
            script = """
            tell application "Terminal"
                if (count of windows) > 0 then
                    tell application "System Events"
                        tell process "Terminal"
                            keystroke "\(text.replacingOccurrences(of: "\n", with: ""))"
                            keystroke return
                        end tell
                    end tell
                end if
            end tell
            """
        case "iTerm2", "iTerm":
            // For iTerm, write text includes the return character
            script = """
            tell application "iTerm"
                if (count of windows) > 0 then
                    tell current session of current tab of current window
                        write text "\(text.replacingOccurrences(of: "\n", with: ""))"
                    end tell
                end if
            end tell
            """
        default:
            return
        }
        
        print("Claude Yes: Sending keystrokes '\(text)' to \(app)")
        executeAppleScript(script)
    }
    
    private func executeAppleScript(_ script: String) -> String {
        guard let appleScript = NSAppleScript(source: script) else {
            print("Claude Yes: Failed to create AppleScript")
            return ""
        }
        
        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        
        if let error = error {
            print("Claude Yes: AppleScript error - \(error)")
            // Don't crash, just return empty
            return ""
        }
        
        return result.stringValue ?? ""
    }
    
    func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}