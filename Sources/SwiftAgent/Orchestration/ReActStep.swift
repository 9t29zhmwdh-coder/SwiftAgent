import Foundation

/// Repräsentiert einen Schritt im ReAct-Loop
public struct ReActStep: Sendable {
    public enum StepType: Sendable {
        case reasoning(String)
        case toolCall(name: String, input: [String: Any])
        case observation(toolName: String, output: String)
        case finalAnswer(String)
    }

    public let iteration: Int
    public let type: StepType
    public let timestamp: Date

    public init(iteration: Int, type: StepType, timestamp: Date = .now) {
        self.iteration = iteration
        self.type = type
        self.timestamp = timestamp
    }
}
