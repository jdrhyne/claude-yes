# Claude Yes for macOS - Project Specification

## 1. Project Overview & Mission

**Project Name:** claude-yes

**Revised Mission Statement:** To create a lightweight, native macOS menu bar utility that automates interacting with command-line AI tools (like claude-code) running in the user's terminal. The application observes the terminal's output and automatically sends "yes" or "proceed" commands, allowing for long, unattended task execution while also intelligently detecting when to pause and alert the user.

**Core Problem Solved:** Manually sitting and waiting to type "1" or "yes" every time a command-line agent asks to proceed is tedious. This utility automates that confirmation loop, turning the agent into a truly autonomous worker, but with safety rails to prevent runaway loops and to request user intervention when necessary.

## 2. Core Concepts & Architecture

- **Menu Bar Native Interface:** The app lives in the macOS menu bar, acting as a simple control panel for the automation engine.
- **Terminal Monitoring & Interaction:** The core of the app is its ability to programmatically read the text content of the user's active terminal window and simulate keyboard input ("1" followed by Enter) back to that window. This will be achieved using macOS Accessibility APIs or AppleScript.
- **Stateful Automation Engine:** The application is built around a state machine:
  - **Idle:** The engine is inactive.
  - **Running:** The engine is actively monitoring the terminal and auto-replying to "proceed" prompts.
  - **Paused (Attention Required):** The engine has detected a situation requiring user input (a specific question, a likely loop, task completion) and has paused automation.
- **Heuristic-Based Logic:** The "intelligence" of the app lies in its ability to parse terminal text to decide its actions based on a set of rules, not by calling an LLM itself.

## 3. Functional Requirements (Key Features)

### 3.1. Menu Bar & Control Interface

- [ ] **Menu Bar Icon:** A distinct icon in the macOS menu bar that changes to reflect the engine's status:
  - **Idle:** Standard icon.
  - **Running:** Icon indicates activity (e.g., a subtle animation or color change).
  - **Paused / Attention Required:** Icon changes noticeably (e.g., turns red, shows a badge) to alert the user.
- [ ] **Main Popover (Control Panel):** Clicking the menu bar icon reveals a simple popover.
  - [ ] **Automation Controls:** A primary button to "Start" / "Stop" the automation engine.
  - [ ] **Automation Limits:** Two user-configurable fields:
    - **Max Proceeds:** A number field to set the maximum times the app will auto-reply before stopping (e.g., 50).
    - **Time Limit (Optional v2):** A field to set a maximum run duration.
  - [ ] **Status Display:** A text area showing the current state (e.g., "Idle", "Running (Proceeded 7/50 times)", "Paused: User input detected").
  - [ ] **Quit Button:** A button to terminate the application.

### 3.2. Automation Engine & Logic

- [ ] **State Management:** Manages the Idle, Running, and Paused states.
- [ ] **Terminal Interaction Service:**
  - A dedicated module to get a reference to the user's active terminal application (e.g., Terminal.app, iTerm2).
  - Reads the visible text content from the active terminal window.
  - Simulates keyboard input to the active terminal window.
- [ ] **Heuristic-Based Decision Logic:** The engine continually analyzes the latest terminal output to make decisions:
  - [ ] **"Proceed" Prompt Detection:** When Running, if the output matches a pattern indicating a confirmation prompt (e.g., contains "Continue?", "proceed?", etc., followed by an option for "1" or "yes"), the engine sends the keypresses 1 and Enter.
  - [ ] **User Input Detection:** The engine must differentiate between a generic "proceed" prompt and a specific question (e.g., "What is the file path?", "Which file should I modify?"). If a specific question is detected, the engine will:
    - Transition to the Paused (Attention Required) state.
    - Change the menu bar icon.
    - Send a macOS notification to the user.
  - [ ] **Task Completion Detection:** The engine will scan for keywords suggesting a task is complete (e.g., "commit message", "Please test the functionality"). If detected, it will pause and notify the user.
  - [ ] **Loop Detection:** The engine will maintain a short history of terminal outputs. If it detects that the last few outputs are nearly identical, it will assume a bug-fixing loop, pause, and notify the user.
  - [ ] **Limit Enforcement:**
    - The engine will track the number of times it has auto-proceeded.
    - It will automatically stop and transition to Idle if the "Max Proceeds" limit is reached. A setting of 0 or empty means unlimited. The initial limit will be 50.

## 4. Technical Specification

- **Platform:** macOS 14.0 (Sonoma) or newer.
- **Language:** Swift 5.10 or newer.
- **Frameworks:** SwiftUI, Foundation, Accessibility, AppleEvents/AppleScriptKit.
- **Permissions:** The application will require Accessibility permissions from the user to read terminal content and simulate input. It must gracefully guide the user on how to grant these permissions in System Settings.
- **Dependencies:** Open-source, community-trusted libraries are permitted.
- **Data Persistence:** UserDefaults will be used to store user settings (e.g., the last used "Max Proceeds" value). No API keys or sensitive data will be stored.

## 5. User Experience (UX) Flow

1. **First Launch:** The app launches, and the menu bar icon appears. On first start, it will check for Accessibility permissions. If not granted, it will show a dialog explaining why they are needed and provide a button to open System Settings.

2. **Standard Workflow:**
   - The user is working with claude-code in their terminal.
   - The user clicks the claude-yes menu bar icon.
   - They verify the "Max Proceeds" limit (e.g., 50).
   - They click "Start". The menu bar icon changes to "Running."
   - The app now monitors the terminal in the background. When claude-code asks to proceed, the app automatically sends the "1" key. The status in the popover might update to "Running (Proceeded 1/50 times)".

3. **Scenario A (User Input Needed):** claude-code asks, "What is the name of the new component?". The app detects this is not a simple "proceed" prompt. It pauses, changes the menu bar icon to red, and sends a notification: "Claude Yes: Attention required in terminal."

4. **Scenario B (Limit Reached):** After the 50th "proceed," the app stops the automation, returns the icon to "Idle," and sends a notification: "Claude Yes: Maximum proceed limit of 50 reached."

5. The user can click "Stop" at any time to manually end the automation.

## Development Notes

- Regular commits should be made to track the project history
- Follow Swift best practices and conventions
- Ensure the app is lightweight and efficient
- Prioritize user privacy and security