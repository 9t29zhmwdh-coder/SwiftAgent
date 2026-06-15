import Foundation

public enum AgentEvent: @unchecked Sendable {
    /// Ein Text-Delta wurde empfangen (Streaming)
    case textDelta(String)
    /// Vollständiger Text einer Iteration
    case textComplete(String)
    /// Ein Tool-Call wurde gestartet
    case toolCallStarted(name: String, input: [String: Any])
    /// Ein Tool-Call wurde abgeschlossen
    case toolCallCompleted(name: String, output: String)
    /// Agent hat finales Ergebnis produziert
    case finished(result: String)
    /// Ein Fehler ist aufgetreten (nicht-fatal)
    case error(Error)
    /// Maximale Iterationen erreicht
    case maxIterationsReached(Int)
}
