import Foundation
@testable import SwiftAgent

actor MockPlugin: AgentPlugin {
    var willCallLLMCount: Int = 0
    var didReceiveResponseCount: Int = 0
    var willUseToolCount: Int = 0
    var didUseToolCount: Int = 0
    var didEncounterErrorCount: Int = 0
    var didFinishCount: Int = 0
    var capturedToolNames: [String] = []

    nonisolated func willCallLLM(messages: [ChatMessage]) async { await _willCallLLM() }
    nonisolated func didReceiveResponse(_ response: ChatResponse) async { await _didReceiveResponse() }
    nonisolated func willUseTool(name: String, input: [String: Any]) async { await _willUseTool(name: name) }
    nonisolated func didUseTool(name: String, input: [String: Any], output: String) async { await _didUseTool() }
    nonisolated func didEncounterError(_ error: Error) async { await _didEncounterError() }
    nonisolated func didFinish(result: String) async { await _didFinish() }

    private func _willCallLLM() { willCallLLMCount += 1 }
    private func _didReceiveResponse() { didReceiveResponseCount += 1 }
    private func _willUseTool(name: String) { willUseToolCount += 1; capturedToolNames.append(name) }
    private func _didUseTool() { didUseToolCount += 1 }
    private func _didEncounterError() { didEncounterErrorCount += 1 }
    private func _didFinish() { didFinishCount += 1 }

    func reset() {
        willCallLLMCount = 0; didReceiveResponseCount = 0
        willUseToolCount = 0; didUseToolCount = 0
        didEncounterErrorCount = 0; didFinishCount = 0
        capturedToolNames.removeAll()
    }
}
