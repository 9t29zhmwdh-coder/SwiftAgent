import Foundation

public protocol Tool: Sendable {
    var name: String { get }
    var description: String { get }
    var parameters: JSONSchema { get }
    func execute(input: [String: Any]) async throws -> String
}

extension Tool {
    public func toDefinition() -> ToolDefinition {
        ToolDefinition(function: .init(
            name: name,
            description: description,
            parameters: parameters
        ))
    }
}

public enum ToolError: LocalizedError, Sendable {
    case notFound(String)
    case executionFailed(toolName: String, underlying: Error)
    case invalidInput(toolName: String, message: String)
    case permissionDenied(toolName: String)

    public var errorDescription: String? {
        switch self {
        case .notFound(let n):
            return "Tool nicht gefunden: \(n)"
        case .executionFailed(let n, let e):
            return "Tool '\(n)' Fehler: \(e.localizedDescription)"
        case .invalidInput(let n, let m):
            return "Ungültige Eingabe für '\(n)': \(m)"
        case .permissionDenied(let n):
            return "Keine Berechtigung für Tool: \(n)"
        }
    }
}
