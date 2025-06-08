# Claude Yes 🤖✅

A lightweight, native macOS menu bar utility that automates interacting with command-line AI tools like [claude-code](https://github.com/anthropics/claude-code).

![Swift](https://img.shields.io/badge/Swift-5.10-orange.svg)
![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 🎯 Overview

Claude Yes automatically responds to confirmation prompts in your terminal, allowing for unattended task execution while intelligently detecting when user input is needed. No more sitting and waiting to type "1" or "yes" every time your AI assistant asks to proceed!

### 🚀 Key Features

- **🖥️ Menu Bar Native**: Lives quietly in your macOS menu bar
- **🤖 Smart Automation**: Automatically sends "1" to proceed prompts
- **🛑 Intelligent Pausing**: Detects when specific user input is needed
- **🔄 Loop Detection**: Prevents infinite loops by detecting repetitive patterns
- **⚙️ Customizable Limits**: Set max auto-replies (default: 50)
- **🔔 Notifications**: Alerts you when attention is needed
- **🏃 Lightweight**: Minimal resource usage, native Swift implementation

## 📋 Requirements

- macOS 14.0 (Sonoma) or newer
- Terminal.app or iTerm2
- Accessibility permissions (for terminal interaction)

## 🛠️ Installation

### Option 1: Build from Source

```bash
# Clone the repository
git clone https://github.com/jdrhyne/claude-yes.git
cd claude-yes

# Build and run
swift build
swift run
```

### Option 2: Download Release (Coming Soon)

Pre-built releases will be available on the [Releases](https://github.com/jdrhyne/claude-yes/releases) page.

## 🚦 Quick Start

1. **Launch Claude Yes**
   ```bash
   swift run
   ```

2. **Look for the icon** in your menu bar (●✓)

3. **Click the icon** and click "Start"

4. **Use claude-code** normally - Claude Yes will handle the prompts!

## 🔧 Configuration

### Setting Up Permissions

On first launch, Claude Yes needs Accessibility permissions:

1. A dialog will appear explaining the permissions
2. Click "Open System Settings"
3. Navigate to **Privacy & Security → Accessibility**
4. Enable Claude Yes
5. Restart the app

### Menu Bar Controls

- **Max Proceeds**: Set the maximum number of auto-responses (0 = unlimited)
- **Start/Stop**: Toggle automation on/off
- **Status Display**: Shows current state and proceed count

## 🧪 Testing & Development

### Test with Included Script

```bash
# Run the test script
./test_prompts.sh
```

This simulates claude-code interaction patterns to verify functionality.

### Understanding the Pattern Detection

Claude Yes detects several types of prompts:

**✅ Auto-Proceed Patterns:**
- `Continue? 1) Yes 2) No`
- `Proceed? (y/n)`
- `Should I continue? [1] Yes`

**🛑 Pause Patterns:**
- `What is the name of...?`
- `Which file should I...?`
- `Please enter the...`
- `Implementation complete!`
- Repeated similar outputs (loop detection)

### Debug Mode

Run with debug output visible:
```bash
swift run
# Watch the terminal for detailed logs
```

## 🐛 Troubleshooting

### "I don't see the menu bar icon"

1. Check if the app is running:
   ```bash
   ps aux | grep claude-yes
   ```

2. Look for overflow menu (>>) if you have many menu bar items

3. Try building in release mode:
   ```bash
   swift build -c release
   .build/release/claude-yes
   ```

### "The app crashes when clicking Start"

1. Ensure Terminal.app or iTerm2 is open
2. Check Accessibility permissions are granted
3. Run in debug mode to see error messages

### "It's not detecting my terminal"

- Currently supports Terminal.app and iTerm2
- Make sure the terminal window is active/focused
- Check Console.app for AppleScript errors

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

```bash
# Run tests
swift test

# Format code (if you have swift-format)
swift-format -i Sources/**/*.swift

# Build for release
swift build -c release
```

## 📝 Known Issues & Limitations

- **App Bundle**: Currently runs as a CLI tool, not a full app bundle
- **Notifications**: Using deprecated NSUserNotification API (works without bundle)
- **Terminal Support**: Only Terminal.app and iTerm2 (VS Code terminal coming soon)
- **Pattern Detection**: May need tuning for specific use cases

## 🗺️ Roadmap

- [ ] Support for more terminal emulators (Alacritty, Kitty, VS Code)
- [ ] Configurable patterns via settings
- [ ] Time-based limits in addition to count limits
- [ ] Export/import pattern configurations
- [ ] Full app bundle with code signing
- [ ] Homebrew formula for easy installation

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- Built for use with [claude-code](https://github.com/anthropics/claude-code)
- Inspired by the need for better AI tool automation
- Thanks to the Swift and macOS developer community

---

**Made with ❤️ for the AI-assisted development community**

*If you find this tool useful, please consider starring the repository!*