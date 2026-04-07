import Foundation
import SwiftUI
import Combine

/// Shared application state — holds all active agent sessions.
/// Updated by SocketServer; observed by NotchPanelView.
class AppState: ObservableObject {
    @Published var sessions: [AgentSession] = []

    private let socketServer = SocketServer()

    var activeSessions: [AgentSession] {
        sessions.filter { $0.status != .idle }
    }

    var latestActiveSession: AgentSession? {
        activeSessions.sorted { $0.timestamp > $1.timestamp }.first
    }

    init() {}

    func startSocketServer() {
        socketServer.start { [weak self] session in
            self?.handleSessionUpdate(session)
        }
    }

    func stopSocketServer() {
        socketServer.stop()
    }

    private func handleSessionUpdate(_ session: AgentSession) {
        if let index = sessions.firstIndex(where: { $0.agentType == session.agentType }) {
            // Update existing session for this agent
            sessions[index] = session
        } else {
            // Add new session
            sessions.append(session)
        }

        // Prune sessions older than 1 hour
        let cutoff = Date().addingTimeInterval(-3600)
        sessions.removeAll { $0.timestamp < cutoff }
    }
}
