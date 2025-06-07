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

## Installation

*Coming soon*

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