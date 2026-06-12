import Foundation

public protocol MemoryStore: Actor {
    func add(message: ChatMessage) async
    func retrieve() async -> [ChatMessage]
    func clear() async
    var count: Int { get async }
}

public enum MemoryError: LocalizedError, Sendable {
    case compressionFailed(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .compressionFailed(let e):
            return "Memory-Komprimierung fehlgeschlagen: \(e.localizedDescription)"
        }
    }
}
