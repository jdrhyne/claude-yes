import Testing
@testable import ClaudeYes

struct DecisionEngineTests {
    
    // MARK: - Proceed Prompt Detection Tests
    
    @Test("Detect proceed prompts", arguments: [
        ("Continue? (y/n)", true),
        ("Would you like to proceed? 1) Yes 2) No", true),
        ("Press 1 to continue, 2 to stop", true),
        ("Should I continue? [1] Yes [2] No", true),
        ("Proceed with the changes? (1) Yes (2) No", true),
        ("Do you want to continue? 1) yes", true),
        ("Continue? y/n", true),
        ("Random text with no prompt", false),
        ("What is your name?", false),
        ("Please enter the file path:", false),
        ("Which component would you like to create?", false),
        ("The task is complete", false)
    ])
    func detectProceedPrompts(output: String, shouldProceed: Bool) {
        let engine = DecisionEngine()
        let result = engine.analyzeOutput(output)
        
        if shouldProceed {
            #expect(result == .proceed)
        } else {
            #expect(result != .proceed)
        }
    }
    
    // MARK: - User Input Detection Tests
    
    @Test("Detect user input required", arguments: [
        ("What is the name of the component?", true),
        ("Which file should I modify?", true),
        ("Please enter the database URL:", true),
        ("What should the function be called?", true),
        ("Where should I place this file?", true),
        ("How should I handle this error?", true),
        ("What would you like to do next?", true),
        ("Please specify the API endpoint:", true),
        ("Provide the configuration file path:", true),
        ("Enter the name of the new class:", true),
        ("Continue? (y/n)", false),
        ("The build completed successfully", false),
        ("All tests are passing", false),
        ("Ready to proceed with next step", false)
    ])
    func detectUserInputRequired(output: String, requiresInput: Bool) {
        let engine = DecisionEngine()
        let result = engine.analyzeOutput(output)
        
        if requiresInput {
            if case .pause(let reason) = result {
                #expect(reason == "User input required")
            } else {
                Issue.record("Expected pause for user input, got \(result)")
            }
        } else {
            if case .pause(let reason) = result {
                #expect(reason != "User input required")
            }
        }
    }
    
    // MARK: - Task Completion Detection Tests
    
    @Test("Detect task completion", arguments: [
        ("The implementation is complete. Please test the functionality.", true),
        ("Task completed successfully. Ready for commit.", true),
        ("Implementation finished. All tests pass.", true),
        ("Done! The feature is ready for review.", true),
        ("Success! The build completed without errors.", true),
        ("Finished implementing the new feature.", true),
        ("All tests pass. The task is complete.", true),
        ("Ready to create a commit message.", true),
        ("Please test the new functionality.", true),
        ("What should I implement next?", false),
        ("Continue with the next step? (y/n)", false),
        ("Building the project...", false),
        ("Running tests...", false)
    ])
    func detectTaskCompletion(output: String, isComplete: Bool) {
        let engine = DecisionEngine()
        let result = engine.analyzeOutput(output)
        
        if isComplete {
            if case .pause(let reason) = result {
                #expect(reason == "Task appears to be complete")
            } else {
                Issue.record("Expected pause for task completion, got \(result)")
            }
        } else {
            if case .pause(let reason) = result {
                #expect(reason != "Task appears to be complete")
            }
        }
    }
    
    // MARK: - Loop Detection Tests
    
    @Test("Detect loops in output")
    func detectLoops() {
        let engine = DecisionEngine()
        
        // Add similar outputs to trigger loop detection
        let similarOutput = "Error: File not found. Please check the path and try again."
        
        // First few outputs should not trigger loop detection
        #expect(engine.analyzeOutput(similarOutput) != .pause(reason: "Potential loop detected - similar outputs repeated"))
        #expect(engine.analyzeOutput(similarOutput) != .pause(reason: "Potential loop detected - similar outputs repeated"))
        
        // Third similar output should trigger loop detection
        let result = engine.analyzeOutput(similarOutput)
        if case .pause(let reason) = result {
            #expect(reason == "Potential loop detected - similar outputs repeated")
        } else {
            Issue.record("Expected loop detection, got \(result)")
        }
    }
    
    // MARK: - Claude Code Specific Patterns
    
    @Test("Claude Code specific proceed patterns", arguments: [
        ("I'll proceed with implementing this feature. Continue? 1) Yes", true),
        ("Should I continue with the next step? 1) Yes 2) No", true),
        ("Ready to make the changes. Proceed? (1) Yes", true),
        ("I can help you with that. Continue? y/n", true),
        ("This will modify your files. Proceed? 1) Yes 2) Cancel", true),
        ("I'll help you implement this. Should I proceed? [1] Yes [2] No", true),
        ("I'll create the component for you. Continue? (y/n)", true)
    ])
    func detectClaudeCodeProceedPatterns(output: String, shouldProceed: Bool) {
        let engine = DecisionEngine()
        let result = engine.analyzeOutput(output)
        
        if shouldProceed {
            #expect(result == .proceed)
        } else {
            #expect(result != .proceed)
        }
    }
    
    @Test("Claude Code specific user input patterns", arguments: [
        ("What is the name of the new component you'd like me to create?", true),
        ("Which framework would you prefer to use for this project?", true),
        ("What should I call this new function?", true),
        ("Where would you like me to place this file?", true),
        ("What type of authentication would you like to implement?", true),
        ("How would you like me to handle error cases?", true),
        ("What's the API endpoint for this service?", true),
        ("Which database would you like to use?", true)
    ])
    func detectClaudeCodeUserInputPatterns(output: String, requiresInput: Bool) {
        let engine = DecisionEngine()
        let result = engine.analyzeOutput(output)
        
        if requiresInput {
            if case .pause(let reason) = result {
                #expect(reason == "User input required")
            } else {
                Issue.record("Expected pause for user input, got \(result)")
            }
        }
    }
    
    @Test("Claude Code completion patterns", arguments: [
        ("I've completed the implementation. Please test the new feature.", true),
        ("The feature is ready. Would you like me to create a commit?", true),
        ("Implementation finished! Please review the changes.", true),
        ("Done! The API integration is complete and tested.", true),
        ("The component has been successfully created. Please test it.", true),
        ("All files have been updated. Ready for commit.", true)
    ])
    func detectClaudeCodeCompletionPatterns(output: String, isComplete: Bool) {
        let engine = DecisionEngine()
        let result = engine.analyzeOutput(output)
        
        if isComplete {
            if case .pause(let reason) = result {
                #expect(reason == "Task appears to be complete")
            } else {
                Issue.record("Expected pause for task completion, got \(result)")
            }
        }
    }
    
    // MARK: - Edge Cases
    
    @Test("Handle empty and malformed input")
    func handleEdgeCases() {
        let engine = DecisionEngine()
        
        // Empty input
        #expect(engine.analyzeOutput("") == .ignore)
        
        // Whitespace only
        #expect(engine.analyzeOutput("   \n\t  ") == .ignore)
        
        // Very long input
        let longInput = String(repeating: "This is a very long string. ", count: 1000)
        let result = engine.analyzeOutput(longInput)
        switch result {
        case .ignore, .proceed, .pause:
            break // All are valid results
        }
    }
    
    @Test("Mixed signal patterns")
    func handleMixedSignals() {
        let engine = DecisionEngine()
        
        // Output that contains both proceed and user input signals
        let mixedOutput = "What is the name of the file? Continue? 1) Yes 2) No"
        let result = engine.analyzeOutput(mixedOutput)
        
        // Should prioritize user input detection over proceed
        if case .pause(let reason) = result {
            #expect(reason == "User input required")
        } else {
            Issue.record("Expected user input detection to take priority, got \(result)")
        }
    }
}