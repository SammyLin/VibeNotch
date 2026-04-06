import Foundation

/// Unix Domain Socket server for receiving hook events from AI agents.
/// M1: Stub implementation — will be connected in M2.
class SocketServer {
    static let socketPath = "/tmp/notch-agent.sock"

    func start() {
        // M2: Implement UDS listener
        print("[SocketServer] Stub — will listen on \(SocketServer.socketPath)")
    }

    func stop() {
        // M2: Cleanup socket
        print("[SocketServer] Stopped")
    }
}
