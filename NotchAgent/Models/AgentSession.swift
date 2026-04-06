import Foundation
import SwiftUI

// MARK: - Agent Type

enum AgentType: String, CaseIterable, Identifiable {
    case claude = "Claude Code"
    case gemini = "Gemini"
    case codex = "Codex"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .claude: return Color(hex: "D97757")
        case .gemini: return Color(hex: "4285F4")
        case .codex: return Color(hex: "10A37F")
        }
    }
}

// MARK: - Agent Status

enum AgentStatus: String, CaseIterable {
    case idle = "Idle"
    case working = "Working"
    case waiting = "Waiting"
    case done = "Done"
    case error = "Error"

    var displayColor: Color {
        switch self {
        case .idle: return .gray
        case .working: return .white
        case .waiting: return Color(hex: "D97757")
        case .done: return Color(hex: "10A37F")
        case .error: return .red
        }
    }
}

// MARK: - Agent Session

struct AgentSession: Identifiable {
    let id: UUID
    let agentType: AgentType
    var status: AgentStatus
    var message: String
    var timestamp: Date
    var project: String

    init(
        id: UUID = UUID(),
        agentType: AgentType,
        status: AgentStatus = .idle,
        message: String = "",
        timestamp: Date = Date(),
        project: String = ""
    ) {
        self.id = id
        self.agentType = agentType
        self.status = status
        self.message = message
        self.timestamp = timestamp
        self.project = project
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        return "\(Int(interval / 3600))h ago"
    }

    var truncatedMessage: String {
        if message.count <= 40 { return message }
        return String(message.prefix(37)) + "..."
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    static let claudeOrange = Color(hex: "D97757")
    static let geminiBlue = Color(hex: "4285F4")
    static let codexGreen = Color(hex: "10A37F")
}
