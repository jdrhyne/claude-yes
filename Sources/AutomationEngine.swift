import Foundation
import Combine
import UserNotifications

enum AutomationState: Equatable {
    case idle
    case running
    case paused(reason: String)
}

class AutomationEngine: ObservableObject {
    @Published var state: AutomationState = .idle
    @Published var maxProceeds: Int = 50
    @Published var proceedCount: Int = 0
    
    private var timer: Timer?
    private let terminalService = TerminalService()
    private let decisionEngine = DecisionEngine()
    
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
        startMonitoring()
    }
    
    func stop() {
        state = .idle
        stopMonitoring()
    }
    
    func pause(reason: String) {
        state = .paused(reason: reason)
        stopMonitoring()
        sendNotification(title: "Claude Yes: Attention Required", body: reason)
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkTerminal()
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkTerminal() {
        guard case .running = state else { return }
        
        let terminalOutput = terminalService.getTerminalOutput()
        
        // Debug output (only show if there's actual content)
        if !terminalOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("Claude Yes: Terminal output detected")
            print("Claude Yes: Output length: \(terminalOutput.count) characters")
        }
        
        let decision = decisionEngine.analyzeOutput(terminalOutput)
        
        switch decision {
        case .proceed:
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
            
        case .ignore:
            // Only log if we actually got content
            if !terminalOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print("Claude Yes: Ignoring output (no matching patterns)")
            }
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}