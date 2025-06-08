import Foundation
import ApplicationServices
import Cocoa

class TerminalService {
    private let supportedTerminals = ["Terminal", "iTerm2", "iTerm"]
    
    func getTerminalOutput() -> String {
        // Check all terminal windows for claude-code sessions
        var allOutput = ""
        
        // Check Terminal.app windows
        let terminalOutput = getAllTerminalAppOutput()
        if !terminalOutput.isEmpty {
            allOutput += terminalOutput + "\n"
        }
        
        // Check iTerm windows  
        let iTermOutput = getAllITermOutput()
        if !iTermOutput.isEmpty {
            allOutput += iTermOutput + "\n"
        }
        
        return allOutput
    }
    
    func sendProceedCommand() {
        // Send to all terminal windows that might have claude sessions
        sendProceedToAllTerminalWindows()
        sendProceedToAllITermWindows()
    }
    
    private func sendProceedToAllTerminalWindows() {
        let script = """
        tell application "Terminal"
            if (count of windows) > 0 then
                repeat with w from 1 to count of windows
                    try
                        set windowOutput to contents of selected tab of window w
                        if windowOutput contains "claude" and (windowOutput contains "proceed" or windowOutput contains "Continue") then
                            tell application "System Events"
                                tell process "Terminal"
                                    set frontmost to true
                                    click window w
                                    keystroke "1"
                                    keystroke return
                                end tell
                            end tell
                        end if
                    end try
                end repeat
            end if
        end tell
        """
        
        executeAppleScript(script)
    }
    
    private func sendProceedToAllITermWindows() {
        let script = """
        tell application "iTerm"
            if (count of windows) > 0 then
                repeat with w from 1 to count of windows
                    try
                        repeat with t from 1 to count of tabs in window w
                            try
                                set sessionOutput to contents of session 1 of tab t of window w
                                if sessionOutput contains "claude" and (sessionOutput contains "proceed" or sessionOutput contains "Continue") then
                                    tell session 1 of tab t of window w
                                        write text "1"
                                    end tell
                                end if
                            end try
                        end repeat
                    end try
                end repeat
            end if
        end tell
        """
        
        executeAppleScript(script)
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
    
    private func getAllTerminalAppOutput() -> String {
        let script = """
        tell application "Terminal"
            set allOutput to ""
            if (count of windows) > 0 then
                repeat with w from 1 to count of windows
                    try
                        set windowOutput to contents of selected tab of window w
                        if windowOutput contains "claude" then
                            set allOutput to allOutput & "WINDOW_" & w & ": " & windowOutput & return
                        end if
                    end try
                end repeat
            end if
            return allOutput
        end tell
        """
        
        return executeAppleScript(script)
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
    
    private func getAllITermOutput() -> String {
        let script = """
        tell application "iTerm"
            set allOutput to ""
            if (count of windows) > 0 then
                repeat with w from 1 to count of windows
                    try
                        repeat with t from 1 to count of tabs in window w
                            try
                                set sessionOutput to contents of session 1 of tab t of window w
                                if sessionOutput contains "claude" then
                                    set allOutput to allOutput & "WINDOW_" & w & "_TAB_" & t & ": " & sessionOutput & return
                                end if
                            end try
                        end repeat
                    end try
                end repeat
            end if
            return allOutput
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