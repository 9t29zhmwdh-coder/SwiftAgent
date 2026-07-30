import Foundation

public struct AgentConfiguration: Sendable {
    public let systemPrompt: String?
    public let temperature: Double?
    public let maxTokens: Int?
    public let maxIterations: Int
    public let streamingEnabled: Bool

    public init(
        systemPrompt: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        maxIterations: Int = 10,
        streamingEnabled: Bool = false
    ) {
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.maxIterations = maxIterations
        self.streamingEnabled = streamingEnabled
    }

    public static let `default` = AgentConfiguration()

    public static let codeAssistant = AgentConfiguration(
        systemPrompt: "Du bist ein hilfreicher Code-Assistent. Schreibe präzisen, gut dokumentierten Swift-Code.",
        temperature: 0.2,
        maxIterations: 15
    )

    public static let generalAssistant = AgentConfiguration(
        systemPrompt: "Du bist ein hilfreicher Assistent. Beantworte Fragen klar und präzise.",
        temperature: 0.7,
        maxIterations: 8
    )
}
