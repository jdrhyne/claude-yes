import Foundation

enum DecisionResult: Equatable {
    case proceed
    case pause(reason: String)
    case ignore
}

class DecisionEngine {
    private var outputHistory: [String] = []
    private let maxHistorySize = 10
    
    func analyzeOutput(_ output: String) -> DecisionResult {
        // Store output in history for loop detection
        addToHistory(output)
        
        // Check for loop patterns
        if detectLoop() {
            return .pause(reason: "Potential loop detected - similar outputs repeated")
        }
        
        // Check for specific user input requests
        if detectUserInputRequired(output) {
            return .pause(reason: "User input required")
        }
        
        // Check for task completion indicators
        if detectTaskCompletion(output) {
            return .pause(reason: "Task appears to be complete")
        }
        
        // Check for proceed prompts
        if detectProceedPrompt(output) {
            return .proceed
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
        guard outputHistory.count >= 3 else { return false }
        
        let recent = Array(outputHistory.suffix(3))
        let similarity = calculateSimilarity(between: recent)
        
        // If the last 3 outputs are very similar, likely a loop
        return similarity > 0.8
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
        
        // Common proceed prompt patterns
        let proceedPatterns = [
            "continue?",
            "proceed?",
            "would you like to proceed",
            "should i continue",
            "press 1 to",
            "1) yes",
            "1) continue",
            "1) proceed",
            "[1]",
            "(1)"
        ]
        
        // Must contain a proceed pattern and some form of confirmation option
        let hasProceedPattern = proceedPatterns.contains { pattern in
            lowercased.contains(pattern)
        }
        
        let hasConfirmationOption = lowercased.contains("1") || 
                                  lowercased.contains("yes") || 
                                  lowercased.contains("y/n")
        
        return hasProceedPattern && hasConfirmationOption
    }
}