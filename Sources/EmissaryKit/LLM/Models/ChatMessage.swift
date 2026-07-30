import Foundation

public struct ChatMessage: Codable, Sendable, Equatable {
    public enum Role: String, Codable, Sendable, Equatable {
        case system, user, assistant, tool
    }

    public let role: Role
    public let content: String
    public let toolCallId: String?
    public let toolCalls: [ToolCall]?

    public init(role: Role, content: String, toolCallId: String? = nil, toolCalls: [ToolCall]? = nil) {
        self.role = role
        self.content = content
        self.toolCallId = toolCallId
        self.toolCalls = toolCalls
    }

    public static func system(_ content: String) -> ChatMessage {
        ChatMessage(role: .system, content: content)
    }
    public static func user(_ content: String) -> ChatMessage {
        ChatMessage(role: .user, content: content)
    }
    public static func assistant(_ content: String, toolCalls: [ToolCall]? = nil) -> ChatMessage {
        ChatMessage(role: .assistant, content: content, toolCalls: toolCalls)
    }
    public static func toolResult(id: String, content: String) -> ChatMessage {
        ChatMessage(role: .tool, content: content, toolCallId: id)
    }

    enum CodingKeys: String, CodingKey {
        case role, content
        case toolCallId = "tool_call_id"
        case toolCalls = "tool_calls"
    }
}
