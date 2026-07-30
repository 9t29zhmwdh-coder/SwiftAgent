import Foundation

/// Komprimiert ältere Nachrichten via LLM-Zusammenfassung, sobald `compressionBatchSize` überschritten wird.
public actor SummaryMemory: MemoryStore {
    private var systemMessages: [ChatMessage] = []
    private var summary: String? = nil
    private var recentMessages: [ChatMessage] = []
    private let llmProvider: any LLMProvider
    public let recentWindowSize: Int
    public let compressionBatchSize: Int

    public init(
        llmProvider: any LLMProvider,
        recentWindowSize: Int = 10,
        compressionBatchSize: Int = 20
    ) {
        self.llmProvider = llmProvider
        self.recentWindowSize = recentWindowSize
        self.compressionBatchSize = compressionBatchSize
    }

    public func add(message: ChatMessage) {
        if message.role == .system {
            systemMessages.append(message)
        } else {
            recentMessages.append(message)
        }
        Task { await self.compressIfNeeded() }
    }

    public func retrieve() -> [ChatMessage] {
        var result = systemMessages
        if let summary {
            result.append(.system("Bisheriger Gesprächsverlauf (zusammengefasst):\n\(summary)"))
        }
        result.append(contentsOf: recentMessages)
        return result
    }

    public func clear() {
        systemMessages.removeAll()
        recentMessages.removeAll()
        summary = nil
    }

    public var count: Int { systemMessages.count + recentMessages.count }

    private func compressIfNeeded() async {
        guard recentMessages.count > recentWindowSize + compressionBatchSize else { return }

        let toCompress = Array(recentMessages.prefix(compressionBatchSize))
        recentMessages = Array(recentMessages.dropFirst(compressionBatchSize))

        let transcript = toCompress.map { "\($0.role.rawValue): \($0.content)" }.joined(separator: "\n")
        let prompt = "Fasse folgenden Gesprächsabschnitt in 3-5 Sätzen zusammen:\n\n\(transcript)"

        do {
            let response = try await llmProvider.chat(messages: [.user(prompt)], tools: nil)
            if let existing = summary {
                summary = "\(existing)\n\(response.content)"
            } else {
                summary = response.content
            }
        } catch {
            // Bei Fehler: Nachrichten behalten statt verlieren
            recentMessages = toCompress + recentMessages
        }
    }
}
