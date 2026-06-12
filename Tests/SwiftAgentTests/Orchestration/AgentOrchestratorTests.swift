import XCTest
@testable import SwiftAgent

final class AgentOrchestratorTests: XCTestCase {

    func testSimpleRunWithoutTools() async throws {
        let provider = MockLLMProvider()
        await provider.setNextResponse(content: "Hallo! Ich bin der Agent.")
        let registry = ToolRegistry()
        let memory = MockMemoryStore()

        let orchestrator = AgentOrchestrator(
            llmProvider: provider, toolRegistry: registry, maxIterations: 5
        )
        let result = try await orchestrator.run(messages: [.user("Hallo")], memory: memory)

        XCTAssertEqual(result, "Hallo! Ich bin der Agent.")
        XCTAssertEqual(await provider.callCount, 1)
    }

    func testMaxIterationsReturnsFallback() async throws {
        let provider = MockLLMProvider()
        let registry = ToolRegistry()
        let tool = MockTool(name: "loop_tool", result: "weiter")
        await registry.register(tool)
        let memory = MockMemoryStore()

        let toolCall = ToolCall(id: "tc1", function: .init(name: "loop_tool", arguments: "{}"))
        await provider.setNextResponse(content: "Iteration", toolCalls: [toolCall])

        let orchestrator = AgentOrchestrator(
            llmProvider: provider, toolRegistry: registry, maxIterations: 2
        )
        let result = try await orchestrator.run(messages: [.user("Loop")], memory: memory)
        XCTAssertTrue(result.contains("2") || result.contains("Maximale"))
    }

    func testPluginsAreNotified() async throws {
        let provider = MockLLMProvider()
        await provider.setNextResponse(content: "Fertig")
        let registry = ToolRegistry()
        let memory = MockMemoryStore()
        let plugin = MockPlugin()

        let orchestrator = AgentOrchestrator(
            llmProvider: provider, toolRegistry: registry, plugins: [plugin], maxIterations: 5
        )
        _ = try await orchestrator.run(messages: [.user("Test")], memory: memory)

        XCTAssertEqual(await plugin.willCallLLMCount, 1)
        XCTAssertEqual(await plugin.didFinishCount, 1)
    }

    func testStreamingFinishEvent() async throws {
        let provider = MockLLMProvider()
        await provider.setNextResponse(content: "Stream-Antwort")
        let registry = ToolRegistry()
        let memory = MockMemoryStore()

        let orchestrator = AgentOrchestrator(
            llmProvider: provider, toolRegistry: registry, maxIterations: 5
        )

        var events: [AgentEvent] = []
        for try await event in orchestrator.runStream(messages: [.user("Stream")], memory: memory) {
            events.append(event)
        }

        let hasFinished = events.contains {
            if case .finished = $0 { return true }
            return false
        }
        XCTAssertTrue(hasFinished)
    }
}
