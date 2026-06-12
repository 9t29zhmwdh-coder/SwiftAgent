import XCTest
@testable import SwiftAgent

final class OpenAICompatibleProviderTests: XCTestCase {

    func testOllamaProviderDefaults() {
        let provider = OllamaProvider()
        XCTAssertEqual(provider.modelName, "llama3.2")
        XCTAssertEqual(provider.baseURL, URL(string: "http://localhost:11434")!)
    }

    func testLlamaCppProviderDefaults() {
        let provider = LlamaCppProvider()
        XCTAssertEqual(provider.modelName, "local-model")
        XCTAssertEqual(provider.baseURL, URL(string: "http://localhost:8080")!)
    }

    func testOllamaCustomConfig() {
        let provider = OllamaProvider(modelName: "mistral", host: "192.168.1.1", port: 9999)
        XCTAssertEqual(provider.modelName, "mistral")
        XCTAssertEqual(provider.baseURL, URL(string: "http://192.168.1.1:9999")!)
    }

    func testHTTP500ThrowsLLMError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockHTTPURLProtocol.self]
        let session = URLSession(configuration: config)

        MockHTTPURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "http://localhost:11434/v1/chat/completions")!,
                statusCode: 500, httpVersion: nil, headerFields: nil
            )!
            return (response, Data("{\"error\":\"Internal Server Error\"}".utf8))
        }

        let provider = OpenAICompatibleProvider(
            modelName: "test",
            baseURL: URL(string: "http://localhost:11434")!,
            urlSession: session
        )

        do {
            _ = try await provider.chat(messages: [.user("test")], tools: nil)
            XCTFail("Sollte einen Fehler werfen")
        } catch let error as LLMError {
            if case .httpError(let code, _) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Falscher Fehlertyp: \(error)")
            }
        } catch {
            XCTFail("Unerwarteter Fehler: \(error)")
        }
    }
}

// MARK: - URLProtocol Mock

final class MockHTTPURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockHTTPURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "NoHandler", code: 0))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
