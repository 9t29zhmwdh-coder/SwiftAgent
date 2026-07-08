import Foundation

/// Führt den ReAct-Loop aus: Reason → Act → Observe → Repeat
public final class AgentOrchestrator: Sendable {
    private let llmProvider: any LLMProvider
    private let toolRegistry: ToolRegistry
    private let plugins: [any AgentPlugin]
    public let maxIterations: Int

    public init(
        llmProvider: any LLMProvider,
        toolRegistry: ToolRegistry,
        plugins: [any AgentPlugin] = [],
        maxIterations: Int = 10
    ) {
        self.llmProvider = llmProvider
        self.toolRegistry = toolRegistry
        self.plugins = plugins
        self.maxIterations = maxIterations
    }

    // MARK: - Nicht-Streaming

    public func run(messages: [ChatMessage], memory: any MemoryStore) async throws -> String {
        var context = await buildContext(messages: messages, memory: memory)
        let toolDefs = await toolRegistry.toolDefinitions

        for iteration in 0..<maxIterations {
            await notifyPlugins { await $0.willCallLLM(messages: context) }
            let response = try await llmProvider.chat(
                messages: context,
                tools: toolDefs.isEmpty ? nil : toolDefs
            )
            await notifyPlugins { await $0.didReceiveResponse(response) }
            await memory.add(message: .assistant(response.content, toolCalls: response.toolCalls))

            guard response.hasToolCalls, let toolCalls = response.toolCalls else {
                let result = response.content
                await notifyPlugins { await $0.didFinish(result: result) }
                return result
            }

            for toolCall in toolCalls {
                let input = (try? toolCall.decodedArguments()) ?? [:]
                await notifyPlugins { await $0.willUseTool(name: toolCall.function.name, input: input) }
                let output: String
                do {
                    output = try await toolRegistry.execute(toolCall: toolCall)
                } catch {
                    output = "Fehler: \(error.localizedDescription)"
                    await notifyPlugins { await $0.didEncounterError(error) }
                }
                await notifyPlugins { await $0.didUseTool(name: toolCall.function.name, input: input, output: output) }
                await memory.add(message: .toolResult(id: toolCall.id, content: output))
            }

            context = await buildContext(messages: messages, memory: memory)

            if iteration == maxIterations - 1 {
                return "Maximale Iterationen (\(maxIterations)) erreicht."
            }
        }
        return "Ausführung abgeschlossen."
    }

    // MARK: - Streaming

    public func runStream(
        messages: [ChatMessage],
        memory: any MemoryStore
    ) -> AsyncThrowingStream<AgentEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var context = await self.buildContext(messages: messages, memory: memory)
                    let toolDefs = await self.toolRegistry.toolDefinitions

                    for iteration in 0..<self.maxIterations {
                        await self.notifyPlugins { await $0.willCallLLM(messages: context) }

                        var fullContent = ""
                        var accumulatedToolCalls: [Int: (id: String, name: String, arguments: String)] = [:]

                        let stream = self.llmProvider.chatStream(
                            messages: context,
                            tools: toolDefs.isEmpty ? nil : toolDefs
                        )

                        for try await chunk in stream {
                            switch chunk.content {
                            case .text(let delta):
                                fullContent += delta
                                continuation.yield(.textDelta(delta))
                            case .toolCallDelta(let index, let id, let name, let argsDelta):
                                var existing = accumulatedToolCalls[index] ?? (id: "", name: "", arguments: "")
                                if let id { existing.id = id }
                                if let name { existing.name = name }
                                if let args = argsDelta { existing.arguments += args }
                                accumulatedToolCalls[index] = existing
                            case .done:
                                break
                            }
                        }

                        if !fullContent.isEmpty {
                            continuation.yield(.textComplete(fullContent))
                        }

                        let toolCalls = accumulatedToolCalls
                            .sorted { $0.key < $1.key }
                            .map { (_, v) in
                                ToolCall(id: v.id, function: .init(name: v.name, arguments: v.arguments))
                            }

                        if toolCalls.isEmpty {
                            await memory.add(message: .assistant(fullContent))
                            continuation.yield(.finished(result: fullContent))
                            continuation.finish()
                            return
                        }

                        await memory.add(message: .assistant(fullContent, toolCalls: toolCalls))

                        for toolCall in toolCalls {
                            let input = (try? toolCall.decodedArguments()) ?? [:]
                            continuation.yield(.toolCallStarted(name: toolCall.function.name, input: input))
                            await self.notifyPlugins { await $0.willUseTool(name: toolCall.function.name, input: input) }

                            let output: String
                            do {
                                output = try await self.toolRegistry.execute(toolCall: toolCall)
                            } catch {
                                output = "Fehler: \(error.localizedDescription)"
                                continuation.yield(.error(error))
                                await self.notifyPlugins { await $0.didEncounterError(error) }
                            }

                            continuation.yield(.toolCallCompleted(name: toolCall.function.name, output: output))
                            await self.notifyPlugins { await $0.didUseTool(
                                name: toolCall.function.name, input: input, output: output
                            )}
                            await memory.add(message: .toolResult(id: toolCall.id, content: output))
                        }

                        context = await self.buildContext(messages: messages, memory: memory)

                        if iteration == self.maxIterations - 1 {
                            continuation.yield(.maxIterationsReached(self.maxIterations))
                            continuation.finish()
                            return
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private

    private func buildContext(messages: [ChatMessage], memory: any MemoryStore) async -> [ChatMessage] {
        let memoryMessages = await memory.retrieve()
        return memoryMessages.isEmpty ? messages : memoryMessages
    }

    // Marking `action` as @Sendable here surfaces stricter capture errors at every call site
    // (mutable `context`, non-Sendable `[String: Any]` tool input), so this stays a warning
    // under the current experimental StrictConcurrency setting rather than a real fix; revisit
    // when adopting full Swift 6 language mode.
    private func notifyPlugins(_ action: @escaping (any AgentPlugin) async -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            for plugin in plugins { group.addTask { await action(plugin) } }
        }
    }
}
