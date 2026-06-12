import Foundation

public protocol AgentPlugin: Sendable {
    func willRun(configuration: AgentConfiguration) async
    func willCallLLM(messages: [ChatMessage]) async
    func didReceiveResponse(_ response: ChatResponse) async
    func willUseTool(name: String, input: [String: Any]) async
    func didUseTool(name: String, input: [String: Any], output: String) async
    func didEncounterError(_ error: Error) async
    func didFinish(result: String) async
}

extension AgentPlugin {
    public func willRun(configuration: AgentConfiguration) async {}
    public func willCallLLM(messages: [ChatMessage]) async {}
    public func didReceiveResponse(_ response: ChatResponse) async {}
    public func willUseTool(name: String, input: [String: Any]) async {}
    public func didUseTool(name: String, input: [String: Any], output: String) async {}
    public func didEncounterError(_ error: Error) async {}
    public func didFinish(result: String) async {}
}

/// Fertige Plugin-Implementierung für Console-Logging
public final class LoggingPlugin: AgentPlugin, @unchecked Sendable {
    private let prefix: String

    public init(prefix: String = "[SwiftAgent]") {
        self.prefix = prefix
    }

    public func willCallLLM(messages: [ChatMessage]) async {
        print("\(prefix) LLM-Anfrage mit \(messages.count) Nachrichten")
    }
    public func willUseTool(name: String, input: [String: Any]) async {
        print("\(prefix) Tool aufgerufen: \(name)")
    }
    public func didUseTool(name: String, input: [String: Any], output: String) async {
        print("\(prefix) Tool-Ergebnis [\(name)]: \(output.prefix(100))...")
    }
    public func didEncounterError(_ error: Error) async {
        print("\(prefix) Fehler: \(error.localizedDescription)")
    }
    public func didFinish(result: String) async {
        print("\(prefix) Fertig: \(result.prefix(200))")
    }
}
