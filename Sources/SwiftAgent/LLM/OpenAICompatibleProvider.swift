import Foundation

public final class OpenAICompatibleProvider: LLMProvider, @unchecked Sendable {
    public let modelName: String
    public let baseURL: URL
    private let urlSession: URLSession
    private let timeoutInterval: TimeInterval
    private let temperature: Double?
    private let maxTokens: Int?

    public init(
        modelName: String,
        baseURL: URL,
        urlSession: URLSession = .shared,
        timeoutInterval: TimeInterval = 300,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) {
        self.modelName = modelName
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.timeoutInterval = timeoutInterval
        self.temperature = temperature
        self.maxTokens = maxTokens
    }

    public func chat(messages: [ChatMessage], tools: [ToolDefinition]?) async throws -> ChatResponse {
        let request = try buildURLRequest(messages: messages, tools: tools, stream: false)
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        do {
            return try JSONDecoder().decode(ChatResponse.self, from: data)
        } catch {
            throw LLMError.decodingError(underlying: error)
        }
    }

    public func chatStream(
        messages: [ChatMessage],
        tools: [ToolDefinition]?
    ) -> AsyncThrowingStream<StreamChunk, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let request = try self.buildURLRequest(messages: messages, tools: tools, stream: true)
                    let (byteStream, response) = try await self.urlSession.bytes(for: request)
                    try self.validate(response: response, data: nil)

                    for try await line in byteStream.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonString = String(line.dropFirst(6))
                        if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                            continuation.yield(StreamChunk(content: .done))
                            continuation.finish()
                            return
                        }
                        guard let data = jsonString.data(using: .utf8) else { continue }
                        let chunk = try JSONDecoder().decode(SSEChatChunk.self, from: data)
                        for choice in chunk.choices {
                            if let text = choice.delta.content, !text.isEmpty {
                                continuation.yield(StreamChunk(
                                    content: .text(text),
                                    finishReason: choice.finishReason
                                ))
                            }
                            if let toolDeltas = choice.delta.toolCalls {
                                for td in toolDeltas {
                                    continuation.yield(StreamChunk(content: .toolCallDelta(
                                        index: td.index,
                                        id: td.id,
                                        name: td.function?.name,
                                        argumentsDelta: td.function?.arguments
                                    ), finishReason: choice.finishReason))
                                }
                            }
                            if choice.finishReason != nil {
                                continuation.yield(StreamChunk(content: .done))
                                continuation.finish()
                                return
                            }
                        }
                    }
                    continuation.yield(StreamChunk(content: .done))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func buildURLRequest(
        messages: [ChatMessage],
        tools: [ToolDefinition]?,
        stream: Bool
    ) throws -> URLRequest {
        let endpoint = baseURL.appendingPathComponent("v1/chat/completions")
        var req = URLRequest(url: endpoint, timeoutInterval: timeoutInterval)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(ChatRequest(
            model: modelName,
            messages: messages,
            tools: tools,
            stream: stream,
            temperature: temperature,
            maxTokens: maxTokens
        ))
        return req
    }

    private func validate(response: URLResponse, data: Data?) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            throw LLMError.httpError(statusCode: http.statusCode, body: body)
        }
    }
}
