import Foundation

public struct StreamChunk: Sendable {
    public enum Content: Sendable {
        case text(String)
        case toolCallDelta(index: Int, id: String?, name: String?, argumentsDelta: String?)
        case done
    }

    public let content: Content
    public let finishReason: String?

    public init(content: Content, finishReason: String? = nil) {
        self.content = content
        self.finishReason = finishReason
    }
}

// Intern: SSE-Parsing
struct SSEChatChunk: Decodable {
    let choices: [SSEChoice]

    struct SSEChoice: Decodable {
        let delta: Delta
        let finishReason: String?

        struct Delta: Decodable {
            let content: String?
            let toolCalls: [ToolCallDelta]?

            enum CodingKeys: String, CodingKey {
                case content
                case toolCalls = "tool_calls"
            }
        }

        struct ToolCallDelta: Decodable {
            let index: Int
            let id: String?
            let function: FunctionDelta?

            struct FunctionDelta: Decodable {
                let name: String?
                let arguments: String?
            }
        }

        enum CodingKeys: String, CodingKey {
            case delta
            case finishReason = "finish_reason"
        }
    }
}
