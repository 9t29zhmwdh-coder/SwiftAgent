import Foundation

public actor ToolRegistry {
    private var tools: [String: any Tool] = [:]

    public init() {}

    public init(tools: [any Tool]) {
        for tool in tools { self.tools[tool.name] = tool }
    }

    public func register(_ tool: any Tool) { tools[tool.name] = tool }
    public func unregister(name: String) { tools.removeValue(forKey: name) }
    public func tool(named name: String) -> (any Tool)? { tools[name] }
    public var allTools: [any Tool] { Array(tools.values) }
    public var toolDefinitions: [ToolDefinition] { tools.values.map { $0.toDefinition() } }
    public var isEmpty: Bool { tools.isEmpty }

    public func execute(toolCall: ToolCall) async throws -> String {
        guard let tool = tools[toolCall.function.name] else {
            throw ToolError.notFound(toolCall.function.name)
        }
        do {
            let args = try toolCall.decodedArguments()
            return try await tool.execute(input: args)
        } catch let error as ToolError {
            throw error
        } catch {
            throw ToolError.executionFailed(toolName: toolCall.function.name, underlying: error)
        }
    }
}
