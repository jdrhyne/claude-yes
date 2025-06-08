# Contributing to Claude Yes

First off, thank you for considering contributing to Claude Yes! 🎉

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Include console output and crash logs**
- **Describe the behavior you observed and expected**
- **Include your macOS version and terminal app**

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **A clear and descriptive title**
- **A detailed description of the proposed enhancement**
- **Explain why this enhancement would be useful**
- **List any alternative solutions you've considered**

### Pull Requests

1. Fork the repo and create your branch from `master`
2. If you've added code that should be tested, add tests
3. Ensure the test suite passes (`swift test`)
4. Make sure your code follows the existing style
5. Write a clear commit message

## Development Process

1. **Set up your environment**:
   ```bash
   git clone https://github.com/jdrhyne/claude-yes.git
   cd claude-yes
   swift build
   swift test
   ```

2. **Make your changes**:
   - Add new patterns to `DecisionEngine.swift`
   - Update tests in `Tests/ClaudeYesTests/`
   - Update documentation as needed

3. **Test thoroughly**:
   - Run the test suite
   - Test with the included `test_prompts.sh`
   - Test with real claude-code sessions

## Code Style

- Use 4 spaces for indentation
- Follow Swift naming conventions
- Keep functions focused and small
- Add comments for complex logic
- Update tests for new functionality

## Pattern Contribution Guidelines

When adding new pattern detection:

1. Add the pattern to the appropriate detection method
2. Add test cases covering the pattern
3. Document the pattern in the README
4. Test with real-world examples

Example:
```swift
// In DecisionEngine.swift
let userInputPatterns = [
    "existing patterns...",
    "your new pattern"  // Add with comment explaining use case
]

// In DecisionEngineTests.swift
@Test("Your new pattern detection", arguments: [
    ("Example input with your pattern", true),
    ("Example without your pattern", false)
])
```

## Questions?

Feel free to open an issue for any questions about contributing!