import Foundation

/// Sliding-Window Memory: behält die letzten `windowSize` Nachrichten + alle System-Prompts.
public actor ConversationMemory: MemoryStore {
    private var messages: [ChatMessage] = []
    public let windowSize: Int

    public init(windowSize: Int = 20) {
        self.windowSize = windowSize
    }

    public func add(message: ChatMessage) {
        messages.append(message)
        trim()
    }

    public func retrieve() -> [ChatMessage] { messages }

    public func retrieveLast(_ n: Int) -> [ChatMessage] {
        Array(messages.suffix(n))
    }

    public func clear() { messages.removeAll() }

    public var count: Int { messages.count }

    private func trim() {
        let systemMessages = messages.filter { $0.role == .system }
        let nonSystem = messages.filter { $0.role != .system }
        guard nonSystem.count > windowSize else { return }
        let trimmed = Array(nonSystem.suffix(windowSize))
        messages = systemMessages + trimmed
    }
}
