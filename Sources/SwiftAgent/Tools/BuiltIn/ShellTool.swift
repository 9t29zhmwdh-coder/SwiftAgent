import Foundation

#if os(macOS)
/// Führt Shell-Befehle aus. Nur auf macOS verfügbar.
public struct ShellTool: Tool {
    public let name = "shell"
    public let description = "Führt Shell-Befehle aus und gibt stdout zurück. Nur macOS."
    public let parameters = JSONSchema.object(
        properties: [
            "command": .string("Auszuführender Shell-Befehl"),
            "workingDirectory": .string("Arbeitsverzeichnis (optional)")
        ],
        required: ["command"]
    )

    private let allowedCommands: Set<String>?
    private let timeoutSeconds: TimeInterval

    public init(allowedCommands: Set<String>? = nil, timeoutSeconds: TimeInterval = 30) {
        self.allowedCommands = allowedCommands
        self.timeoutSeconds = timeoutSeconds
    }

    public func execute(input: [String: Any]) async throws -> String {
        guard let command = input["command"] as? String else {
            throw ToolError.invalidInput(toolName: name, message: "command fehlt")
        }

        if let allowed = allowedCommands {
            let base = command.components(separatedBy: " ").first ?? ""
            guard allowed.contains(base) else {
                throw ToolError.permissionDenied(toolName: name)
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", command]

            if let wd = input["workingDirectory"] as? String {
                process.currentDirectoryURL = URL(fileURLWithPath: wd)
            }

            let pipe = Pipe()
            let errPipe = Pipe()
            process.standardOutput = pipe
            process.standardError = errPipe

            do {
                try process.run()
                process.waitUntilExit()
                let outData = pipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                var result = String(data: outData, encoding: .utf8) ?? ""
                let errStr = String(data: errData, encoding: .utf8) ?? ""
                if !errStr.isEmpty { result += "\n[stderr]: \(errStr)" }
                continuation.resume(returning: result.trimmingCharacters(in: .whitespacesAndNewlines))
            } catch {
                continuation.resume(throwing: ToolError.executionFailed(toolName: name, underlying: error))
            }
        }
    }
}
#endif
