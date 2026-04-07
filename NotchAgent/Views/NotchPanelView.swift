import SwiftUI

struct NotchPanelView: View {
    @ObservedObject var appState: AppState
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 0) {
            if isHovering && !appState.sessions.isEmpty {
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
            if appState.activeSessions.isEmpty {
                Circle()
                    .fill(.gray.opacity(0.4))
                    .frame(width: 6, height: 6)
            } else {
                // Status emoji badge
                Text(appState.latestActiveSession?.status.emoji ?? "😐")
                    .font(.system(size: 14))
                    .shadow(color: .black.opacity(0.5), radius: 2)

                if let latest = appState.latestActiveSession {
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
            HStack {
                Text("NotchAgent")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(appState.activeSessions.count) active")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, 4)

            Divider()
                .background(.white.opacity(0.1))

            ForEach(appState.sessions) { session in
                AgentRowView(session: session)
                if session.id != appState.sessions.last?.id {
                    Divider()
                        .background(.white.opacity(0.05))
                }
            }
        }
        .padding(12)
        .frame(width: 280)
    }
}
