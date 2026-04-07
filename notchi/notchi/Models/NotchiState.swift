import AppKit

enum VibeNotchTask: String, CaseIterable {
    case idle, working, sleeping, compacting, waiting

    var bobDuration: Double {
        switch self {
        case .sleeping:   return 4.0
        case .idle, .waiting: return 1.5
        case .working:    return 0.4
        case .compacting: return 0.5
        }
    }

    var bobAmplitude: CGFloat {
        switch self {
        case .sleeping, .compacting: return 0
        case .idle:                  return 1.5
        case .waiting:               return 0.5
        case .working:               return 0.5
        }
    }

    var canWalk: Bool {
        switch self {
        case .sleeping, .compacting, .waiting:
            return false
        case .idle, .working:
            return true
        }
    }

    var displayName: String {
        switch self {
        case .idle:       return "Idle"
        case .working:    return "Working..."
        case .sleeping:   return "Sleeping"
        case .compacting: return "Compacting..."
        case .waiting:    return "Waiting..."
        }
    }

    var emoji: String {
        switch self {
        case .idle:       return "🦞"
        case .working:    return "⚙️"
        case .sleeping:   return "😴"
        case .compacting: return "🤔"
        case .waiting:    return "⏳"
        }
    }

    var walkFrequencyRange: ClosedRange<Double> {
        switch self {
        case .sleeping, .waiting: return 30.0...60.0
        case .idle:               return 8.0...15.0
        case .working:            return 5.0...12.0
        case .compacting:         return 15.0...25.0
        }
    }
}

enum VibeNotchEmotion: String, CaseIterable {
    case neutral, happy, sad, sob

    var swayAmplitude: Double {
        switch self {
        case .neutral: return 0.5
        case .happy:   return 1.0
        case .sad:     return 0.25
        case .sob:     return 0.15
        }
    }

    var emojiModifier: String? {
        switch self {
        case .happy: return "✅"
        case .sad:   return "❌"
        case .sob:   return "❌"
        case .neutral: return nil
        }
    }
}

struct VibeNotchState: Equatable {
    var task: VibeNotchTask
    var emotion: VibeNotchEmotion = .neutral

    var emoji: String {
        if emotion == .happy && task == .idle {
            return "✅"
        }
        if emotion == .sad || emotion == .sob {
            return "❌"
        }
        return task.emoji
    }

    var bobDuration: Double { task.bobDuration }
    var bobAmplitude: CGFloat {
        switch emotion {
        case .sob: return 0
        case .sad: return task.bobAmplitude * 0.5
        default:   return task.bobAmplitude
        }
    }
    var swayAmplitude: Double { emotion.swayAmplitude }
    var canWalk: Bool { emotion == .sob ? false : task.canWalk }
    var displayName: String { task.displayName }
    var walkFrequencyRange: ClosedRange<Double> { task.walkFrequencyRange }

    static let idle = VibeNotchState(task: .idle)
    static let working = VibeNotchState(task: .working)
    static let sleeping = VibeNotchState(task: .sleeping)
    static let compacting = VibeNotchState(task: .compacting)
    static let waiting = VibeNotchState(task: .waiting)
}
