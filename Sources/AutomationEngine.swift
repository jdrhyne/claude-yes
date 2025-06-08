import Foundation
import Combine
import Cocoa

enum AutomationState: Equatable {
    case idle
    case running
    case paused(reason: String)
}

class AutomationEngine: ObservableObject {
    @Published var state: AutomationState = .idle
    @Published var maxProceeds: Int = 50
    @Published var proceedCount: Int = 0
    @Published var activeSessions: Int = 0
    
    private var timer: Timer?
    private let terminalService = TerminalService()
    private let decisionEngine = DecisionEngine()
    private var lastProcessedOutput: String = ""
    
    var statusText: String {
        switch state {
        case .idle:
            return "Idle"
        case .running:
            return "Running (Proceeded \(proceedCount)/\(maxProceeds == 0 ? "∞" : "\(maxProceeds)") times)"
        case .paused(let reason):
            return "Paused: \(reason)"
        }
    }
    
    func start() {
        guard state == .idle else { return }
        
        state = .running
        proceedCount = 0
        lastProcessedOutput = ""  // Clear last processed output
        decisionEngine.clearHistory()  // Clear history when starting fresh
        startMonitoring()
    }
    
    func stop() {
        state = .idle
        stopMonitoring()
    }
    
    func pause(reason: String) {
        state = .paused(reason: reason)
        // Don't stop monitoring - keep watching for auto-resume opportunities
        sendNotification(title: "Claude Yes: Attention Required", body: reason)
    }
    
    func autoResume() {
        // Reset proceed count and resume monitoring
        proceedCount = 0
        state = .running
        sendNotification(title: "Claude Yes: Auto-Resumed", body: "New task detected - proceed count reset to 0")
        print("Claude Yes: Auto-resumed with proceed count reset to 0")
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkTerminal()
        }
        print("Claude Yes: Started monitoring terminal")
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkTerminal() {
        // Continue monitoring even when paused to detect auto-resume opportunities
        switch state {
        case .running, .paused:
            break // Continue processing
        case .idle:
            return // Don't process when idle
        }
        
        let terminalOutput = terminalService.getTerminalOutput()
        
        // Skip if we've already processed this exact output
        if terminalOutput == lastProcessedOutput {
            return
        }
        
        // Debug output (only show if there's actual content)
        let trimmedOutput = terminalOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedOutput.isEmpty {
            // Count how many claude sessions we found
            let claudeWindows = terminalOutput.components(separatedBy: "WINDOW_").count - 1
            activeSessions = claudeWindows
            print("Claude Yes: Found \(claudeWindows) claude sessions across all terminal windows")
            print("Claude Yes: Terminal output detected")
            print("Claude Yes: Output length: \(terminalOutput.count) characters")
            
            // Show last 500 chars AND look for proceed patterns in the entire output
            let preview = String(trimmedOutput.suffix(500))
            print("Claude Yes: Output preview (last 500 chars): '\(preview)'")
            
            // Also check if "proceed" appears anywhere in the full output
            if trimmedOutput.lowercased().contains("proceed") {
                print("Claude Yes: Found 'proceed' in output!")
                // Find the line with "proceed" and show it
                let lines = trimmedOutput.components(separatedBy: .newlines)
                for line in lines.reversed() {
                    if line.lowercased().contains("proceed") {
                        print("Claude Yes: Proceed line: '\(line.trimmingCharacters(in: .whitespaces))'")
                        break
                    }
                }
            }
        }
        
        lastProcessedOutput = terminalOutput
        let decision = decisionEngine.analyzeOutput(terminalOutput)
        
        switch decision {
        case .proceed:
            // Only proceed if we're in running state
            guard case .running = state else { return }
            
            if maxProceeds > 0 && proceedCount >= maxProceeds {
                pause(reason: "Maximum proceed limit of \(maxProceeds) reached")
                return
            }
            
            print("Claude Yes: Sending proceed command (count: \(proceedCount + 1))")
            terminalService.sendProceedCommand()
            proceedCount += 1
            
        case .pause(let reason):
            print("Claude Yes: Pausing - \(reason)")
            pause(reason: reason)
            
        case .autoResume:
            print("Claude Yes: Auto-resuming - new task detected")
            autoResume()
            
        case .ignore:
            // Only log if we actually got content and we're running
            if case .running = state, !terminalOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print("Claude Yes: Ignoring output (no matching patterns)")
            }
        }
    }
    
    private func sendNotification(title: String, body: String) {
        // Use NSUserNotification for now (deprecated but works without app bundle)
        DispatchQueue.main.async {
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = body
            notification.soundName = NSUserNotificationDefaultSoundName
            
            NSUserNotificationCenter.default.deliver(notification)
            print("Claude Yes: Notification sent - \(title)")
        }
    }
}