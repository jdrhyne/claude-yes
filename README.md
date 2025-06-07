# Claude Yes

A lightweight, native macOS menu bar utility that automates interacting with command-line AI tools like claude-code.

## Overview

Claude Yes automatically responds to confirmation prompts in your terminal, allowing for unattended task execution while intelligently detecting when user input is needed.

## Features

- **Menu Bar Interface**: Simple control panel living in your macOS menu bar
- **Smart Automation**: Automatically sends "1" or "yes" to proceed prompts
- **Intelligent Pausing**: Detects when specific user input is needed and pauses
- **Loop Detection**: Identifies repetitive patterns and prevents infinite loops
- **Customizable Limits**: Set maximum auto-replies to prevent runaway execution
- **Native macOS App**: Built with Swift and SwiftUI for optimal performance

## Requirements

- macOS 14.0 (Sonoma) or newer
- Accessibility permissions (for terminal interaction)

## Installation & Development

### Building from Source

1. **Clone the repository**:
   ```bash
   git clone https://github.com/jdrhyne/claude-yes.git
   cd claude-yes
   ```

2. **Build the project**:
   ```bash
   swift build
   ```

3. **Run tests** (optional):
   ```bash
   swift test
   ```

4. **Launch the app**:
   ```bash
   swift run
   ```

### Setting Up Permissions

When you first run Claude Yes, it will request Accessibility permissions:

1. The app will show a dialog explaining the need for permissions
2. Click "Open System Settings" 
3. Go to **Privacy & Security → Accessibility**
4. Add Claude Yes to the list of allowed apps
5. Restart the app

### Local Testing & Debugging

#### Testing with a Simple Script

Create a test script to simulate claude-code prompts:

```bash
# Create test script
cat > test_prompts.sh << 'EOF'
#!/bin/bash
echo "I'll help you implement this feature."
echo "Continue? 1) Yes 2) No"
read -p "Enter choice: " choice
echo "You chose: $choice"

echo ""
echo "What is the name of the component?"
read -p "Component name: " name
echo "Component name: $name"

echo ""
echo "Implementation complete! Please test the functionality."
echo "Continue? (y/n)"
read -p "Enter choice: " final
echo "Final choice: $final"
EOF

chmod +x test_prompts.sh
```

#### Testing Workflow

1. **Start Claude Yes**:
   ```bash
   swift run
   ```

2. **Open a new terminal** and run the test script:
   ```bash
   ./test_prompts.sh
   ```

3. **Click the Claude Yes menu bar icon** and click "Start"

4. **Watch the automation**:
   - Should automatically respond "1" to the first prompt
   - Should pause and notify you for the "What is the name" question
   - Should pause for the completion message

#### Debugging Tips

- **Check Console.app** for any error messages from Claude Yes
- **Terminal output**: The app prints debug info to the terminal where you ran `swift run`
- **Notification Center**: Watch for Claude Yes notifications when it pauses
- **Menu bar icon**: Changes color/style based on state (idle/running/paused)

#### Testing with Real Claude Code

1. Start Claude Yes (`swift run`)
2. In another terminal, start a claude-code session
3. Click "Start" in Claude Yes menu bar
4. Begin a task with claude-code that requires multiple confirmations
5. Observe the automation and pausing behavior

## Usage

1. Launch Claude Yes - the icon appears in your menu bar
2. Click the icon to open the control panel
3. Set your preferred "Max Proceeds" limit (default: 50)
4. Click "Start" to begin automation
5. The app will monitor your terminal and auto-respond to proceed prompts

The app will pause and notify you when:
- A specific question requires your input
- A potential loop is detected
- The task appears to be complete
- The proceed limit is reached

## Development

Built with:
- Swift 5.10+
- SwiftUI
- macOS Accessibility APIs

## License

*License information to be added*