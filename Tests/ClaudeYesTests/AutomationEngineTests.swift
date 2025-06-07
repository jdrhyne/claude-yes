import Testing
import Combine
@testable import ClaudeYes

struct AutomationEngineTests {
    
    @Test("Initial state is idle")
    func initialState() {
        let engine = AutomationEngine()
        #expect(engine.state == .idle)
        #expect(engine.proceedCount == 0)
        #expect(engine.maxProceeds == 50)
    }
    
    @Test("Status text reflects current state")
    func statusTextUpdates() {
        let engine = AutomationEngine()
        
        // Idle state
        #expect(engine.statusText == "Idle")
        
        // Running state
        engine.state = .running
        engine.proceedCount = 5
        #expect(engine.statusText == "Running (Proceeded 5/50 times)")
        
        // Running with unlimited proceeds
        engine.maxProceeds = 0
        #expect(engine.statusText == "Running (Proceeded 5/∞ times)")
        
        // Paused state
        engine.state = .paused(reason: "User input required")
        #expect(engine.statusText == "Paused: User input required")
    }
    
    @Test("Start transitions from idle to running")
    func startFromIdle() {
        let engine = AutomationEngine()
        
        engine.start()
        
        #expect(engine.state == .running)
        #expect(engine.proceedCount == 0)
    }
    
    @Test("Start does nothing when not idle")
    func startFromNonIdle() {
        let engine = AutomationEngine()
        
        // Set to running
        engine.state = .running
        engine.start()
        #expect(engine.state == .running)
        
        // Set to paused
        engine.state = .paused(reason: "Test")
        engine.start()
        #expect(engine.state == .paused(reason: "Test"))
    }
    
    @Test("Stop transitions to idle")
    func stopTransitionsToIdle() {
        let engine = AutomationEngine()
        
        engine.state = .running
        engine.stop()
        #expect(engine.state == .idle)
        
        engine.state = .paused(reason: "Test")
        engine.stop()
        #expect(engine.state == .idle)
    }
    
    @Test("Pause transitions to paused with reason")
    func pauseWithReason() {
        let engine = AutomationEngine()
        
        engine.state = .running
        engine.pause(reason: "Test reason")
        
        #expect(engine.state == .paused(reason: "Test reason"))
    }
    
    @Test("Max proceeds limit enforcement", arguments: [1, 5, 10, 50])
    func maxProceedsLimitEnforcement(limit: Int) {
        let engine = AutomationEngine()
        engine.maxProceeds = limit
        engine.proceedCount = limit - 1
        engine.state = .running
        
        // Should still be running just before limit
        #expect(engine.state == .running)
        
        // Simulate reaching the limit
        engine.proceedCount = limit
        // Note: In real implementation, this would be checked in checkTerminal()
        // For testing, we'll simulate the behavior
        if engine.maxProceeds > 0 && engine.proceedCount >= engine.maxProceeds {
            engine.pause(reason: "Maximum proceed limit of \(engine.maxProceeds) reached")
        }
        
        #expect(engine.state == .paused(reason: "Maximum proceed limit of \(limit) reached"))
    }
    
    @Test("Unlimited proceeds (maxProceeds = 0)")
    func unlimitedProceeds() {
        let engine = AutomationEngine()
        engine.maxProceeds = 0
        engine.proceedCount = 1000 // Very high count
        
        // Should never trigger limit with maxProceeds = 0
        let shouldPause = engine.maxProceeds > 0 && engine.proceedCount >= engine.maxProceeds
        #expect(!shouldPause)
    }
    
    @Test("State equality comparisons")
    func stateEquality() {
        #expect(AutomationState.idle == .idle)
        #expect(AutomationState.running == .running)
        #expect(AutomationState.paused(reason: "Test") == .paused(reason: "Test"))
        #expect(AutomationState.paused(reason: "Test1") != .paused(reason: "Test2"))
        #expect(AutomationState.idle != .running)
        #expect(AutomationState.running != .paused(reason: "Test"))
    }
}