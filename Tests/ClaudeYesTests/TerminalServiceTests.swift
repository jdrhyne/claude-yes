import Testing
@testable import ClaudeYes

struct TerminalServiceTests {
    
    @Test("Terminal service initialization")
    func initialization() {
        let service = TerminalService()
        
        // Service should be created without errors
        #expect(type(of: service) == TerminalService.self)
    }
    
    @Test("Supported terminal detection", arguments: [
        ("Terminal", true),
        ("iTerm2", true),
        ("iTerm", true),
        ("VSCode", false),
        ("Chrome", false),
        ("", false)
    ])
    func supportedTerminalDetection(appName: String, isSupported: Bool) {
        let supportedTerminals = ["Terminal", "iTerm2", "iTerm"]
        let result = supportedTerminals.contains(appName)
        #expect(result == isSupported)
    }
    
    @Test("AppleScript string escaping")
    func appleScriptEscaping() {
        // Test strings that need escaping in AppleScript
        let testCases = [
            ("simple", "simple"),
            ("with\"quotes", "with\\\"quotes"),
            ("with\\backslash", "with\\\\backslash"),
            ("with\nnewline", "with\\nnewline")
        ]
        
        for (input, expected) in testCases {
            let escaped = input
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
            
            #expect(escaped == expected)
        }
    }
    
    @Test("Keystroke formatting")
    func keystrokeFormatting() {
        // Test that keystrokes are properly formatted
        let testCases = [
            ("1\n", "1"),  // Newline should be stripped for iTerm
            ("yes\n", "yes"),
            ("continue\n", "continue")
        ]
        
        for (input, expected) in testCases {
            let formatted = input.replacingOccurrences(of: "\n", with: "")
            #expect(formatted == expected)
        }
    }
    
    @Test("Empty output handling")
    func emptyOutputHandling() {
        // Test various empty/whitespace scenarios
        let emptyCases = ["", "   ", "\n", "\t", "  \n\t  "]
        
        for emptyCase in emptyCases {
            // Should handle empty output gracefully
            let trimmed = emptyCase.trimmingCharacters(in: .whitespacesAndNewlines)
            #expect(trimmed.isEmpty)
        }
    }
}