import SwiftUI

struct MenuBarView: View {
    @ObservedObject var automationEngine: AutomationEngine
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.title2)
                Text("Claude Yes")
                    .font(.headline)
                Spacer()
            }
            
            // Status
            Text(automationEngine.statusText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Controls
            VStack(spacing: 12) {
                HStack {
                    Text("Max Proceeds:")
                    Spacer()
                    TextField("50", value: $automationEngine.maxProceeds, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                        .disabled(automationEngine.state != .idle)
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        if case .idle = automationEngine.state {
                            automationEngine.start()
                        } else {
                            automationEngine.stop()
                        }
                    }) {
                        Text(buttonText)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    if case .paused = automationEngine.state {
                        Button("Resume") {
                            // Clear history and resume from fresh state
                            automationEngine.state = .idle
                            automationEngine.start()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
            }
            
            Divider()
            
            // Quit button
            Button("Quit Claude Yes") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .frame(width: 280)
    }
    
    private var iconName: String {
        switch automationEngine.state {
        case .idle:
            return "circle"
        case .running:
            return "checkmark.circle.fill"
        case .paused:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var iconColor: Color {
        switch automationEngine.state {
        case .idle:
            return .secondary
        case .running:
            return .green
        case .paused:
            return .orange
        }
    }
    
    private var buttonText: String {
        switch automationEngine.state {
        case .idle:
            return "Start"
        case .running:
            return "Stop"
        case .paused:
            return "Stop"
        }
    }
}