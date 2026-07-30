import Foundation

public struct ChatResponse: Codable, Sendable {
    public let id: String
    public let model: String
    public let choices: [Choice]
    public let usage: Usage?

    public struct Choice: Codable, Sendable {
        public let index: Int
        public let message: ChatMessage
        public let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }

    public struct Usage: Codable, Sendable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }

    public var firstMessage: ChatMessage? { choices.first?.message }
    public var content: String { firstMessage?.content ?? "" }
    public var toolCalls: [ToolCall]? { firstMessage?.toolCalls }
    public var hasToolCalls: Bool { !(toolCalls?.isEmpty ?? true) }
}
