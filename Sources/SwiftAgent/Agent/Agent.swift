import Foundation

public enum AgentError: LocalizedError, Sendable {
    case notConfigured
    case maxIterationsExceeded(Int)
    case runCancelled
    case providerError(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .notConfigured: return "Agent nicht konfiguriert"
        case .maxIterationsExceeded(let n): return "Maximale Iterationen überschritten: \(n)"
        case .runCancelled: return "Agent-Run abgebrochen"
        case .providerError(let e): return "Provider-Fehler: \(e.localizedDescription)"
        }
    }
}

/// Haupt-Actor des Frameworks.
///
/// Fasst LLMProvider, ToolRegistry, Memory und AgentOrchestrator zusammen.
///
/// ```swift
/// let agent = Agent(provider: OllamaProvider(), tools: [FilesystemTool()], configuration: .codeAssistant)
/// let result = try await agent.run("Analysiere die Dateien in /tmp")
/// ```
public actor Agent {
    private let provider: any LLMProvider
    private let registry: ToolRegistry
    private let memory: any MemoryStore
    private let orchestrator: AgentOrchestrator
    public let configuration: AgentConfiguration

    public init(
        provider: any LLMProvider,
        tools: [any Tool] = [],
        memory: (any MemoryStore)? = nil,
        plugins: [any AgentPlugin] = [],
        configuration: AgentConfiguration = .default
    ) {
        self.provider = provider
        self.configuration = configuration
        self.registry = ToolRegistry(tools: tools)
        self.memory = memory ?? ConversationMemory(windowSize: 20)
        self.orchestrator = AgentOrchestrator(
            llmProvider: provider,
            toolRegistry: registry,
            plugins: plugins,
            maxIterations: configuration.maxIterations
        )
    }

    // MARK: - Convenience-Initializer

    public static func ollama(
        modelName: String = "llama3.2",
        tools: [any Tool] = [],
        configuration: AgentConfiguration = .default
    ) -> Agent {
        Agent(provider: OllamaProvider(modelName: modelName), tools: tools, configuration: configuration)
    }

    public static func llamaCpp(
        modelName: String = "local-model",
        tools: [any Tool] = [],
        configuration: AgentConfiguration = .default
    ) -> Agent {
        Agent(provider: LlamaCppProvider(modelName: modelName), tools: tools, configuration: configuration)
    }

    // MARK: - Tool-Verwaltung

    public func registerTool(_ tool: any Tool) async { await registry.register(tool) }
    public func unregisterTool(named name: String) async { await registry.unregister(name: name) }

    // MARK: - Run (nicht-streaming)

    /// Führt einen Agent-Run durch und gibt das finale Ergebnis zurück.
    public func run(_ userMessage: String) async throws -> String {
        var messages: [ChatMessage] = []
        if let sys = configuration.systemPrompt { messages.append(.system(sys)) }
        messages.append(.user(userMessage))
        return try await orchestrator.run(messages: messages, memory: memory)
    }

    // MARK: - Run (streaming)

    /// Führt einen Agent-Run mit Streaming durch.
    public func runStream(_ userMessage: String) -> AsyncThrowingStream<AgentEvent, Error> {
        var messages: [ChatMessage] = []
        if let sys = configuration.systemPrompt { messages.append(.system(sys)) }
        messages.append(.user(userMessage))
        return orchestrator.runStream(messages: messages, memory: memory)
    }

    // MARK: - Multi-Turn Konversation

    /// Führt eine Multi-Turn Konversation durch (Memory wird beibehalten).
    public func chat(_ userMessage: String) async throws -> String {
        await memory.add(message: .user(userMessage))
        var contextMessages: [ChatMessage] = []
        if let sys = configuration.systemPrompt { contextMessages.append(.system(sys)) }
        return try await orchestrator.run(messages: contextMessages, memory: memory)
    }

    // MARK: - Memory

    public func clearMemory() async { await memory.clear() }

    public var messageCount: Int {
        get async { await memory.count }
    }
}
