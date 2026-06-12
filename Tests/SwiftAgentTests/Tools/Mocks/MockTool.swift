import Foundation
@testable import SwiftAgent

struct MockTool: Tool {
    let name: String
    let description: String
    let parameters: JSONSchema

    let executeResult: String
    let executeError: Error?
    private let state: MockToolState

    init(name: String = "mock_tool", description: String = "Ein Mock-Tool", result: String = "Mock-Ergebnis") {
        self.name = name
        self.description = description
        self.parameters = .object(properties: ["input": .string("Eingabe")])
        self.executeResult = result
        self.executeError = nil
        self.state = MockToolState()
    }

    func execute(input: [String: Any]) async throws -> String {
        await state.record(input: input)
        if let error = executeError { throw error }
        return executeResult
    }

    var capturedInputs: [[String: Any]] {
        get async { await state.inputs }
    }
}

actor MockToolState {
    var inputs: [[String: Any]] = []
    func record(input: [String: Any]) { inputs.append(input) }
}
