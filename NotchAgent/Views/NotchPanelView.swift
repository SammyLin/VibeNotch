import SwiftUI

struct NotchPanelView: View {
    @StateObject private var viewModel = NotchPanelViewModel()
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 0) {
            if isHovering && !viewModel.sessions.isEmpty {
                expandedView
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                collapsedView
            }
        }
        .background(
            RoundedRectangle(cornerRadius: isHovering ? 16 : 20)
                .fill(.black.opacity(0.85))
                .shadow(color: .black.opacity(0.3), radius: 8, y: 2)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    // MARK: - Collapsed View (dots only)

    private var collapsedView: some View {
        HStack(spacing: 6) {
            if viewModel.activeSessions.isEmpty {
                Circle()
                    .fill(.gray.opacity(0.4))
                    .frame(width: 6, height: 6)
            } else {
                ForEach(viewModel.activeSessions) { session in
                    AgentDotView(session: session)
                }

                if let latest = viewModel.latestActiveSession {
                    Text(latest.truncatedMessage)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                        .frame(maxWidth: 200)

                    Text(latest.timeAgo)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Expanded View (full details)

    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                Text("NotchAgent")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(viewModel.activeSessions.count) active")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, 4)

            Divider()
                .background(.white.opacity(0.1))

            // Agent rows
            ForEach(viewModel.sessions) { session in
                AgentRowView(session: session)
                if session.id != viewModel.sessions.last?.id {
                    Divider()
                        .background(.white.opacity(0.05))
                }
            }
        }
        .padding(12)
        .frame(width: 280)
    }
}

// MARK: - ViewModel with Mock Data

class NotchPanelViewModel: ObservableObject {
    @Published var sessions: [AgentSession]

    var activeSessions: [AgentSession] {
        sessions.filter { $0.status != .idle }
    }

    var latestActiveSession: AgentSession? {
        activeSessions.sorted { $0.timestamp > $1.timestamp }.first
    }

    init() {
        // M1: Mock data for UI verification
        self.sessions = [
            AgentSession(
                agentType: .claude,
                status: .working,
                message: "Refactoring auth middleware...",
                timestamp: Date().addingTimeInterval(-120),
                project: "notch-agent"
            ),
            AgentSession(
                agentType: .gemini,
                status: .waiting,
                message: "Permission: write to /src/db.ts?",
                timestamp: Date().addingTimeInterval(-45),
                project: "api-server"
            ),
            AgentSession(
                agentType: .codex,
                status: .done,
                message: "Added unit tests for parser",
                timestamp: Date().addingTimeInterval(-600),
                project: "data-pipeline"
            ),
        ]
    }
}
