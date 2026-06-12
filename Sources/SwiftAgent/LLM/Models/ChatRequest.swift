import Foundation

struct ChatRequest: Codable, Sendable {
    let model: String
    let messages: [ChatMessage]
    let tools: [ToolDefinition]?
    let stream: Bool
    let temperature: Double?
    let maxTokens: Int?

    init(
        model: String,
        messages: [ChatMessage],
        tools: [ToolDefinition]? = nil,
        stream: Bool = false,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) {
        self.model = model
        self.messages = messages
        self.tools = tools.flatMap { $0.isEmpty ? nil : $0 }
        self.stream = stream
        self.temperature = temperature
        self.maxTokens = maxTokens
    }

    enum CodingKeys: String, CodingKey {
        case model, messages, tools, stream, temperature
        case maxTokens = "max_tokens"
    }
}
