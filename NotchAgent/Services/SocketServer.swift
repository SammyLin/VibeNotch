import Foundation

// MARK: - Socket Event

struct SocketEvent: Codable {
    let event: String       // "idle" | "thinking" | "working" | "completed" | "error"
    let agent: String       // "claude-code" | "gemini" | "codex"
    let timestamp: TimeInterval
    let hook_event: String?
    let data: [String: String]?
}

// MARK: - Socket Server

/// Unix Domain Socket server for receiving hook events from AI agents.
class SocketServer {
    static let socketPath = "/tmp/notch-agent.sock"

    private var stateUpdateHandler: ((AgentSession) -> Void)?
    private let queue = DispatchQueue(label: "com.openclaw.notch-agent.socket", qos: .userInitiated)

    // MARK: - Start / Stop

    func start(stateUpdateHandler: @escaping (AgentSession) -> Void) {
        self.stateUpdateHandler = stateUpdateHandler

        // Remove stale socket
        try? FileManager.default.removeItem(atPath: SocketServer.socketPath)

        // Create socket
        let listenSocket = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
        guard listenSocket >= 0 else {
            print("[SocketServer] Failed to create socket")
            return
        }

        // Build sockaddr_un manually to avoid exclusivity violation
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathBytes = SocketServer.socketPath.utf8CString
        let pathLen = min(pathBytes.count - 1, MemoryLayout.size(ofValue: addr.sun_path) - 1)
        let sunPathSize = MemoryLayout.size(ofValue: addr.sun_path)
        withUnsafeMutablePointer(to: &addr.sun_path) { pathPtr in
            pathPtr.withMemoryRebound(to: CChar.self, capacity: sunPathSize) { buf in
                for i in 0..<pathLen {
                    buf[i] = pathBytes[i]
                }
                buf[pathLen] = 0
            }
        }

        let addrLen = socklen_t(MemoryLayout<sockaddr_un>.size)
        let bindResult = withUnsafePointer(to: &addr) { addrPtr in
            addrPtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                bind(listenSocket, sockaddrPtr, addrLen)
            }
        }

        guard bindResult == 0 else {
            print("[SocketServer] Bind failed: \(String(cString: strerror(errno)))")
            close(listenSocket)
            return
        }

        // Make socket writable by other processes (agents)
        chmod(SocketServer.socketPath, mode_t(S_IRWXU | S_IRWXG | S_IRWXO))

        guard listen(listenSocket, 5) == 0 else {
            print("[SocketServer] Listen failed")
            close(listenSocket)
            return
        }

        print("[SocketServer] Listening on \(SocketServer.socketPath)")

        // Accept connections in background
        let socketQueue = DispatchQueue(label: "com.openclaw.notch-agent.uds")
        socketQueue.async { [weak self] in
            self?.acceptLoop(socket: listenSocket)
        }
    }

    func stop() {
        try? FileManager.default.removeItem(atPath: SocketServer.socketPath)
        print("[SocketServer] Stopped")
    }

    // MARK: - Accept Loop

    private func acceptLoop(socket: Int32) {
        while true {
            let clientSocket = accept(socket, nil, nil)
            if clientSocket < 0 {
                if errno == EINTR { continue }
                break
            }

            // Handle client in background
            queue.async { [weak self] in
                self?.handleClient(socket: clientSocket)
            }
        }
    }

    // MARK: - Handle Client

    private func handleClient(socket: Int32) {
        defer { close(socket) }

        var buffer = [UInt8](repeating: 0, count: 4096)
        var messageData = Data()

        while true {
            let n = read(socket, &buffer, buffer.count)
            if n <= 0 { break }

            messageData.append(contentsOf: buffer.prefix(n))

            // Try to parse complete JSON messages (delimited by newline)
            while let range = messageData.range(of: Data("\n".utf8)) {
                let jsonData = messageData.subdata(in: 0..<range.lowerBound)
                messageData.removeSubrange(0..<range.upperBound)

                if let session = parseEvent(jsonData) {
                    DispatchQueue.main.async { [weak self] in
                        self?.stateUpdateHandler?(session)
                    }
                }
            }
        }
    }

    // MARK: - Parse Event

    private func parseEvent(_ data: Data) -> AgentSession? {
        guard let socketEvent = try? JSONDecoder().decode(SocketEvent.self, from: data) else {
            // Try parsing without strict decode
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let eventStr = json["event"] as? String,
               let agentStr = json["agent"] as? String {
                return buildSession(event: eventStr, agent: agentStr, json: json)
            }
            return nil
        }

        return buildSession(event: socketEvent.event, agent: socketEvent.agent, json: nil)
    }

    private func buildSession(event: String, agent: String, json: [String: Any]?) -> AgentSession {
        let agentType: AgentType
        switch agent.lowercased() {
        case "claude-code", "claude": agentType = .claude
        case "gemini": agentType = .gemini
        case "codex": agentType = .codex
        default: agentType = .claude
        }

        let status: AgentStatus
        switch event.lowercased() {
        case "idle": status = .idle
        case "thinking": status = .working
        case "working": status = .working
        case "completed", "done": status = .done
        case "error": status = .error
        default: status = .idle
        }

        var message = ""
        if let data = json?["data"] as? [String: String] {
            message = data["message"] ?? data["description"] ?? ""
        } else if let data = json?["data"] as? [String: Any] {
            message = (data["message"] ?? data["description"]) as? String ?? ""
        }

        return AgentSession(
            agentType: agentType,
            status: status,
            message: message,
            timestamp: Date(),
            project: ""
        )
    }
}


