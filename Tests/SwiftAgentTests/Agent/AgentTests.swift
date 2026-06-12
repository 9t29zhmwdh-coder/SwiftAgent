import XCTest
@testable import SwiftAgent

final class AgentTests: XCTestCase {

    func testBasicRun() async throws {
        let provider = MockLLMProvider()
        await provider.setNextResponse(content: "Willkommen!")
        let agent = Agent(provider: provider)
        let result = try await agent.run("Hallo!")
        XCTAssertEqual(result, "Willkommen!")
    }

    func testSystemPromptIsSent() async throws {
        let provider = MockLLMProvider()
        await provider.setNextResponse(content: "Ich bin ein Code-Assistent")
        let agent = Agent(
            provider: provider,
            configuration: .init(systemPrompt: "Du bist ein Code-Assistent.")
        )
        _ = try await agent.run("Zeige ein Beispiel")
        let messages = await provider.capturedMessages.first
        XCTAssertNotNil(messages)
        let systemMsg = messages?.first { $0.role == .system }
        XCTAssertEqual(systemMsg?.content, "Du bist ein Code-Assistent.")
    }

    func testClearMemory() async throws {
        let provider = MockLLMProvider()
        await provider.setNextResponse(content: "Antwort")
        let agent = Agent(provider: provider)
        _ = try await agent.run("Test")
        await agent.clearMemory()
        XCTAssertEqual(await agent.messageCount, 0)
    }

    func testStreamingRunFinishes() async throws {
        let provider = MockLLMProvider()
        await provider.setNextResponse(content: "Stream-Test")
        let agent = Agent(provider: provider)
        var allEvents: [AgentEvent] = []
        for try await event in agent.runStream("Streaming Test") {
            allEvents.append(event)
        }
        let hasFinished = allEvents.contains {
            if case .finished = $0 { return true }
            return false
        }
        XCTAssertTrue(hasFinished)
    }

    func testOllamaConvenienceInit() {
        let agent = Agent.ollama(modelName: "mistral")
        XCTAssertNotNil(agent)
    }

    func testLlamaCppConvenienceInit() {
        let agent = Agent.llamaCpp(modelName: "phi3")
        XCTAssertNotNil(agent)
    }

    func testConfigurationDefaults() {
        let config = AgentConfiguration.default
        XCTAssertNil(config.systemPrompt)
        XCTAssertEqual(config.maxIterations, 10)
        XCTAssertFalse(config.streamingEnabled)
    }

    func testCodeAssistantConfiguration() {
        let config = AgentConfiguration.codeAssistant
        XCTAssertNotNil(config.systemPrompt)
        XCTAssertEqual(config.temperature, 0.2)
        XCTAssertEqual(config.maxIterations, 15)
    }
}
