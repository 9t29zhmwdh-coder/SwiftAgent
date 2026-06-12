import Foundation
@testable import SwiftAgent

actor MockLLMProvider: LLMProvider {
    nonisolated let modelName: String
    nonisolated let baseURL: URL

    var nextResponse: ChatResponse?
    var nextError: Error?
    var capturedMessages: [[ChatMessage]] = []
    var capturedTools: [[ToolDefinition]?] = []
    var callCount: Int = 0

    init(modelName: String = "mock-model", baseURL: URL = URL(string: "http://localhost:11434")!) {
        self.modelName = modelName
        self.baseURL = baseURL
    }

    nonisolated func chat(messages: [ChatMessage], tools: [ToolDefinition]?) async throws -> ChatResponse {
        try await _chat(messages: messages, tools: tools)
    }

    private func _chat(messages: [ChatMessage], tools: [ToolDefinition]?) async throws -> ChatResponse {
        callCount += 1
        capturedMessages.append(messages)
        capturedTools.append(tools)
        if let error = nextError { throw error }
        return nextResponse ?? makeDefaultResponse("Mock-Antwort \(callCount)")
    }

    nonisolated func chatStream(
        messages: [ChatMessage],
        tools: [ToolDefinition]?
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let (text, error) = await self._streamState()
                if let error {
                    continuation.finish(throwing: error)
                    return
                }
                let content = text ?? "Mock-Stream-Antwort"
                for char in content.unicodeScalars {
                    continuation.yield(StreamChunk(content: .text(String(char))))
                }
                continuation.yield(StreamChunk(content: .done))
                continuation.finish()
            }
        }
    }

    private func _streamState() -> (String?, Error?) {
        (nextResponse?.content, nextError)
    }

    func setNextResponse(content: String, toolCalls: [ToolCall]? = nil) {
        nextResponse = makeDefaultResponse(content, toolCalls: toolCalls)
    }

    func setNextError(_ error: Error) { nextError = error }

    func reset() {
        nextResponse = nil; nextError = nil
        capturedMessages.removeAll(); capturedTools.removeAll(); callCount = 0
    }

    private func makeDefaultResponse(_ content: String, toolCalls: [ToolCall]? = nil) -> ChatResponse {
        ChatResponse(
            id: "mock-\(UUID().uuidString)",
            model: modelName,
            choices: [.init(
                index: 0,
                message: .assistant(content, toolCalls: toolCalls),
                finishReason: toolCalls != nil ? "tool_calls" : "stop"
            )],
            usage: .init(promptTokens: 10, completionTokens: 20, totalTokens: 30)
        )
    }
}
