import Foundation

public final class OllamaProvider: LLMProvider, @unchecked Sendable {
    private let underlying: OpenAICompatibleProvider
    public var modelName: String { underlying.modelName }
    public var baseURL: URL { underlying.baseURL }

    public init(modelName: String = "llama3.2", host: String = "localhost", port: Int = 11434) {
        let url = URL(string: "http://\(host):\(port)")!
        self.underlying = OpenAICompatibleProvider(modelName: modelName, baseURL: url)
    }

    public func chat(messages: [ChatMessage], tools: [ToolDefinition]?) async throws -> ChatResponse {
        try await underlying.chat(messages: messages, tools: tools)
    }

    public func chatStream(
        messages: [ChatMessage],
        tools: [ToolDefinition]?
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        underlying.chatStream(messages: messages, tools: tools)
    }
}
