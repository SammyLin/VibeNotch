import SwiftUI

struct StatusIndicator: View {
    let session: AgentSession
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(indicatorColor)
            .frame(width: 8, height: 8)
            .shadow(color: indicatorColor.opacity(0.6), radius: shadowRadius)
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing && session.status == .waiting ? 0.4 : 1.0)
            .onAppear { startAnimation() }
            .onChange(of: session.status) { startAnimation() }
    }

    private var indicatorColor: Color {
        switch session.status {
        case .idle:
            return .gray
        case .working, .waiting, .done, .error:
            return session.agentType.color
        }
    }

    private var shadowRadius: CGFloat {
        switch session.status {
        case .idle: return 0
        case .working, .waiting: return 4
        case .done, .error: return 2
        }
    }

    private func startAnimation() {
        isPulsing = false
        switch session.status {
        case .working:
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        case .waiting:
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        default:
            withAnimation(.default) {
                isPulsing = false
            }
        }
    }
}

// MARK: - Compact Row (for collapsed notch bar)

struct AgentDotView: View {
    let session: AgentSession

    var body: some View {
        StatusIndicator(session: session)
            .help(session.agentType.rawValue)
    }
}

// MARK: - Expanded Row (for hover panel)

struct AgentRowView: View {
    let session: AgentSession

    var body: some View {
        HStack(spacing: 8) {
            StatusIndicator(session: session)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(session.agentType.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Text(session.status.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(session.status.displayColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(session.status.displayColor.opacity(0.15))
                        .cornerRadius(4)
                }

                if !session.message.isEmpty {
                    Text(session.truncatedMessage)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }

                HStack {
                    if !session.project.isEmpty {
                        Text(session.project)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Spacer()
                    Text(session.timeAgo)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 4)
    }
}
