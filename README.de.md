<div align="center">
  <img src="RayStudio.png" alt="RayStudio Logo" width="120"/>

  <h1>SwiftAgent</h1>
</div>

[English](README.md)

# SwiftAgent

[![CI](https://github.com/9t29zhmwdh-coder/SwiftAgent/actions/workflows/ci.yml/badge.svg)](https://github.com/9t29zhmwdh-coder/SwiftAgent/actions) ![Apple Silicon](https://img.shields.io/badge/Apple-Silicon-000000?logo=apple&logoColor=white) ![Platform](https://img.shields.io/badge/Platform-macOS_%7C_iOS-lightgrey?logo=apple&logoColor=black) ![Swift](https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white) ![AI | Claude Code](https://img.shields.io/badge/AI-Claude_Code-black?logo=anthropic&logoColor=white) ![AI | Copilot](https://img.shields.io/badge/AI-Copilot-black?logo=github&logoColor=white) ![AI | Ollama](https://img.shields.io/badge/AI-Ollama-black?logo=ollama&logoColor=white)

Ein leichtgewichtiges, modulares Swift-Agent-Framework für lokale LLMs; keine externen Abhängigkeiten, reines Foundation + URLSession.

Funktioniert direkt mit **Ollama** (Port 11434) und **llama.cpp** (Port 8080) über deren OpenAI-kompatible APIs.

---

## Features

- **Keine externen Abhängigkeiten**: nur Foundation + URLSession
- **Swift Concurrency**: async/await, Actors, AsyncStream
- **ReAct-Loop**: Reason → Act → Observe (mehrstufige Tool-Nutzung)
- **Streaming**: Server-Sent Events (SSE) mit `AsyncThrowingStream`
- **Tool-System**: JSON Schema, OpenAI Function-Calling-Format, eingebaute Tools
- **Memory**: Sliding-Window + LLM-basierte Zusammenfassungskomprimierung
- **Plugin-Architektur**: Lifecycle-Hooks für Logging, Monitoring, Tracing
- **macOS 13+ und iOS 16+**: eine Codebasis, kein plattformspezifischer Core

---

## Anforderungen

- Swift 5.9+
- macOS 13+ / iOS 16+
- [Ollama](https://ollama.com) (Port 11434) **oder** [llama.cpp-Server](https://github.com/ggerganov/llama.cpp) (Port 8080)

---

## Schnellstart

### Ollama

```swift
import SwiftAgent

let agent = Agent.ollama(modelName: "llama3.2")
let result = try await agent.run("Was ist die Fibonacci-Folge?")
print(result)
```

### llama.cpp

```swift
let agent = Agent.llamaCpp(modelName: "phi3")
let result = try await agent.run("Erkläre Swift Concurrency.")
print(result)
```

### Agent mit Tools

```swift
let agent = Agent(
    provider: OllamaProvider(modelName: "llama3.2"),
    tools: [
        FilesystemTool(allowedBasePath: URL(fileURLWithPath: "/tmp")),
        HTTPTool(allowedHosts: ["api.example.com"]),
        ShellTool()  // nur macOS
    ],
    configuration: .codeAssistant
)

let result = try await agent.run("Lese /tmp/notes.txt und fasse den Inhalt zusammen.")
```

### Streaming

```swift
for try await event in agent.runStream("Schreibe ein Haiku über Swift") {
    switch event {
    case .textDelta(let chunk):
        print(chunk, terminator: "")
    case .toolCallStarted(let name, _):
        print("\n[Tool: \(name)]")
    case .finished(let result):
        print("\nFertig: \(result)")
    case .error(let err):
        print("Fehler: \(err)")
    default:
        break
    }
}
```

### Multi-Turn Konversation

```swift
let agent = Agent(
    provider: OllamaProvider(modelName: "mistral"),
    configuration: .generalAssistant
)

let r1 = try await agent.chat("Mein Name ist Rafael.")
let r2 = try await agent.chat("Wie heisse ich?")  // Agent erinnert sich
```

### Eigenes Tool

```swift
struct WetterTool: Tool {
    let name = "get_weather"
    let description = "Gibt das aktuelle Wetter für eine Stadt zurück."
    let parameters = JSONSchema.object(
        properties: ["city": .string("Stadtname")],
        required: ["city"]
    )

    func execute(input: [String: Any]) async throws -> String {
        let city = input["city"] as? String ?? "unbekannt"
        return "Sonnig, 22°C in \(city)"
    }
}

let agent = Agent(provider: OllamaProvider(), tools: [WetterTool()])
```

### Logging-Plugin

```swift
let agent = Agent(
    provider: OllamaProvider(),
    plugins: [LoggingPlugin()]
)
```

---

## Architektur

```
Agent (Actor)
├── AgentConfiguration
├── LLMProvider (Protokoll)
│   ├── OllamaProvider     → OpenAICompatibleProvider
│   └── LlamaCppProvider   → OpenAICompatibleProvider
├── ToolRegistry (Actor)
│   └── Tool (Protokoll)
│       ├── FilesystemTool
│       ├── ShellTool       (nur macOS)
│       └── HTTPTool
├── MemoryStore (Protokoll)
│   ├── ConversationMemory  (Sliding Window)
│   └── SummaryMemory       (LLM-basierte Komprimierung)
└── AgentOrchestrator       (ReAct-Loop)
    └── AgentPlugin (Protokoll)
        └── LoggingPlugin
```

---

## Tests ausführen

```bash
cd /path/to/SwiftAgent
swift test
```


---

**Autor:** [Rafael Yilmaz](https://github.com/9t29zhmwdh-coder) · **Status:** Active · v0.1.0 · **Lizenz:** MIT

