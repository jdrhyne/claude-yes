import Foundation

enum DecisionResult: Equatable {
    case proceed
    case pause(reason: String)
    case autoResume
    case ignore
}

class DecisionEngine {
    private var outputHistory: [String] = []
    private let maxHistorySize = 10
    private var wasLastTaskComplete = false
    
    func clearHistory() {
        outputHistory.removeAll()
        wasLastTaskComplete = false
        print("Claude Yes: Decision engine history cleared")
    }
    
    func analyzeOutput(_ output: String) -> DecisionResult {
        // Store output in history for loop detection
        addToHistory(output)
        
        // Debug: Print what we're analyzing
        if !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("Claude Yes: Analyzing output for patterns...")
        }
        
        // TEMPORARILY DISABLE loop detection to debug other issues
        // if detectLoop() {
        //     return .pause(reason: "Potential loop detected - similar outputs repeated")
        // }
        
        // Check for specific user input requests
        if detectUserInputRequired(output) {
            print("Claude Yes: DETECTED user input required")
            return .pause(reason: "User input required")
        }
        
        // Check for task completion indicators
        if detectTaskCompletion(output) {
            print("Claude Yes: DETECTED task completion")
            wasLastTaskComplete = true
            return .pause(reason: "Task appears to be complete")
        }
        
        // Check if user manually continued after task completion (auto-resume)
        if wasLastTaskComplete && detectNewTaskStarted(output) {
            print("Claude Yes: DETECTED new task started - auto-resuming")
            wasLastTaskComplete = false
            return .autoResume
        }
        
        // Check for proceed prompts
        if detectProceedPrompt(output) {
            print("Claude Yes: DETECTED proceed prompt")
            return .proceed
        }
        
        if !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("Claude Yes: No patterns matched - ignoring")
        }
        return .ignore
    }
    
    private func addToHistory(_ output: String) {
        outputHistory.append(output)
        if outputHistory.count > maxHistorySize {
            outputHistory.removeFirst()
        }
    }
    
    private func detectLoop() -> Bool {
        guard outputHistory.count >= 5 else { return false }
        
        let recent = Array(outputHistory.suffix(5))
        let similarity = calculateSimilarity(between: recent)
        
        // Only detect as loop if last 5 outputs are VERY similar (>95%)
        // This prevents false positives from similar prompts
        return similarity > 0.95
    }
    
    private func calculateSimilarity(between outputs: [String]) -> Double {
        guard outputs.count >= 2 else { return 0.0 }
        
        var totalSimilarity = 0.0
        var comparisons = 0
        
        for i in 0..<outputs.count {
            for j in (i+1)..<outputs.count {
                totalSimilarity += stringSimilarity(outputs[i], outputs[j])
                comparisons += 1
            }
        }
        
        return comparisons > 0 ? totalSimilarity / Double(comparisons) : 0.0
    }
    
    private func stringSimilarity(_ str1: String, _ str2: String) -> Double {
        let distance = levenshteinDistance(str1, str2)
        let maxLength = max(str1.count, str2.count)
        return maxLength > 0 ? 1.0 - (Double(distance) / Double(maxLength)) : 1.0
    }
    
    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let s1 = Array(str1)
        let s2 = Array(str2)
        
        var matrix = Array(repeating: Array(repeating: 0, count: s2.count + 1), count: s1.count + 1)
        
        for i in 0...s1.count {
            matrix[i][0] = i
        }
        
        for j in 0...s2.count {
            matrix[0][j] = j
        }
        
        for i in 1...s1.count {
            for j in 1...s2.count {
                let cost = s1[i-1] == s2[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,
                    matrix[i][j-1] + 1,
                    matrix[i-1][j-1] + cost
                )
            }
        }
        
        return matrix[s1.count][s2.count]
    }
    
    private func detectUserInputRequired(_ output: String) -> Bool {
        let lowercased = output.lowercased()
        
        // Patterns that indicate specific user input is needed
        let userInputPatterns = [
            "what is",
            "which file",
            "which framework",
            "which database",
            "enter the",
            "provide the",
            "what should",
            "where should",
            "where would you like",
            "how should",
            "how would you like",
            "what would you like",
            "what type of",
            "what's the",
            "please specify",
            "please enter",
            "name of the",
            "path to the"
        ]
        
        return userInputPatterns.contains { pattern in
            lowercased.contains(pattern)
        }
    }
    
    private func detectTaskCompletion(_ output: String) -> Bool {
        let lowercased = output.lowercased()
        
        // Patterns that suggest task completion
        let completionPatterns = [
            "commit message",
            "please test",
            "testing complete",
            "implementation complete",
            "task completed",
            "finished",
            "done",
            "success",
            "all tests pass"
        ]
        
        return completionPatterns.contains { pattern in
            lowercased.contains(pattern)
        }
    }
    
    private func detectProceedPrompt(_ output: String) -> Bool {
        let lowercased = output.lowercased()
        
        // Common proceed prompt patterns (more specific to claude-code)
        let proceedPatterns = [
            "continue?",
            "proceed?",
            "do you want to proceed",
            "would you like to proceed",
            "should i continue",
            "should i proceed", 
            "continue with",
            "shall i continue",
            "shall i proceed",
            "want to proceed"
        ]
        
        // Must contain a proceed pattern
        let hasProceedPattern = proceedPatterns.contains { pattern in
            lowercased.contains(pattern)
        }
        
        // Must also have some confirmation mechanism
        let hasConfirmationOption = lowercased.contains("1)") || 
                                  lowercased.contains("[1]") ||
                                  lowercased.contains("(1)") ||
                                  lowercased.contains("1) yes") ||
                                  lowercased.contains("(y/n)") ||
                                  lowercased.contains("y/n") ||
                                  lowercased.contains("1 -") ||
                                  lowercased.contains("1:") ||
                                  lowercased.contains("1 ") ||
                                  (lowercased.contains("proceed") && lowercased.contains("1"))
        
        let result = hasProceedPattern && hasConfirmationOption
        
        if result {
            print("Claude Yes: DETECTED PROCEED PROMPT in: '\(String(output.suffix(100)))'")
        }
        
        return result
    }
    
    private func detectNewTaskStarted(_ output: String) -> Bool {
        let lowercased = output.lowercased()
        
        // Patterns that indicate a new task has started
        let newTaskPatterns = [
            "i'll help you",
            "i can help",
            "let me help",
            "sure, i can",
            "i'll implement",
            "i'll create",
            "i'll add",
            "i'll build",
            "let's implement",
            "let's create",
            "let's add",
            "let's build",
            "what would you like",
            "how can i help",
            "what do you need",
            "what should we",
            "i'll start by",
            "let me start",
            "first, i'll",
            "i understand you want",
            "i'll work on"
        ]
        
        let hasNewTaskPattern = newTaskPatterns.contains { pattern in
            lowercased.contains(pattern)
        }
        
        if hasNewTaskPattern {
            print("Claude Yes: DETECTED new task pattern in: '\(String(output.suffix(100)))'")
        }
        
        return hasNewTaskPattern
    }
}