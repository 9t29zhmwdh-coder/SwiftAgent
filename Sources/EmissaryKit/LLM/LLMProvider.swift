import Foundation

public protocol LLMProvider: Sendable {
    var modelName: String { get }
    var baseURL: URL { get }

    func chat(messages: [ChatMessage], tools: [ToolDefinition]?) async throws -> ChatResponse
    func chatStream(messages: [ChatMessage], tools: [ToolDefinition]?) -> AsyncThrowingStream<StreamChunk, Error>
}

public enum LLMError: LocalizedError, Sendable {
    case invalidURL(String)
    case httpError(statusCode: Int, body: String)
    case decodingError(underlying: Error)
    case streamingError(message: String)
    case timeout
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Ungültige URL: \(url)"
        case .httpError(let code, let body): return "HTTP Fehler \(code): \(body)"
        case .decodingError(let err): return "Dekodierungsfehler: \(err.localizedDescription)"
        case .streamingError(let msg): return "Streaming-Fehler: \(msg)"
        case .timeout: return "Anfrage-Timeout"
        case .cancelled: return "Anfrage abgebrochen"
        }
    }
}
