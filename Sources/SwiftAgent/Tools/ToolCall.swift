import Foundation

public struct ToolCall: Codable, Sendable, Equatable {
    public let id: String
    public let type: String
    public let function: FunctionCall

    public struct FunctionCall: Codable, Sendable, Equatable {
        public let name: String
        public let arguments: String
    }

    public init(id: String, type: String = "function", function: FunctionCall) {
        self.id = id
        self.type = type
        self.function = function
    }

    public func decodedArguments() throws -> [String: Any] {
        guard let data = function.arguments.data(using: .utf8) else { return [:] }
        let decoded = try JSONSerialization.jsonObject(with: data)
        return decoded as? [String: Any] ?? [:]
    }
}

public struct ToolDefinition: Codable, Sendable {
    public let type: String
    public let function: FunctionDefinition

    public struct FunctionDefinition: Codable, Sendable {
        public let name: String
        public let description: String
        public let parameters: JSONSchema
    }

    public init(function: FunctionDefinition) {
        self.type = "function"
        self.function = function
    }
}
