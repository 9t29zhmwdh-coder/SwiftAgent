[Deutsch](README.de.md)

# SwiftAgent

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B%20%7C%20iOS%2016%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-green)

A lightweight, modular Swift agent framework for local LLMs — no external dependencies, pure Foundation + URLSession.

Works out of the box with **Ollama** (port 11434) and **llama.cpp** (port 8080) via their OpenAI-compatible APIs.

---

## Features

- **Zero external dependencies** — Foundation + URLSession only
- **Swift Concurrency** — async/await, actors, AsyncStream
- **ReAct Loop** — Reason → Act → Observe (multi-step tool use)
- **Streaming** — Server-Sent Events (SSE) with `AsyncThrowingStream`
- **Tool System** — JSON Schema, OpenAI function-calling format, built-in tools
- **Memory** — Sliding-window + LLM-based summary compression
- **Plugin Architecture** — Lifecycle hooks for logging, monitoring, tracing
- **macOS 13+ and iOS 16+** — single codebase, no platform-specific core

---

## Requirements

- Swift 5.9+
- macOS 13+ / iOS 16+
- [Ollama](https://ollama.com) (port 11434) **or** [llama.cpp server](https://github.com/ggerganov/llama.cpp) (port 8080)

---

## Quick Start

### Ollama

```swift
import SwiftAgent

let agent = Agent.ollama(modelName: "llama3.2")
let result = try await agent.run("What is the Fibonacci sequence?")
print(result)
```

### llama.cpp

```swift
let agent = Agent.llamaCpp(modelName: "phi3")
let result = try await agent.run("Explain Swift Concurrency.")
print(result)
```

### Agent with Tools

```swift
let agent = Agent(
    provider: OllamaProvider(modelName: "llama3.2"),
    tools: [
        FilesystemTool(allowedBasePath: URL(fileURLWithPath: "/tmp")),
        HTTPTool(allowedHosts: ["api.example.com"]),
        ShellTool()  // macOS only
    ],
    configuration: .codeAssistant
)

let result = try await agent.run("Read /tmp/notes.txt and summarize the content.")
```

### Streaming

```swift
for try await event in agent.runStream("Write a haiku about Swift") {
    switch event {
    case .textDelta(let chunk):
        print(chunk, terminator: "")
    case .toolCallStarted(let name, _):
        print("\n[Tool: \(name)]")
    case .finished(let result):
        print("\nDone: \(result)")
    case .error(let err):
        print("Error: \(err)")
    default:
        break
    }
}
```

### Multi-Turn Conversation

```swift
let agent = Agent(
    provider: OllamaProvider(modelName: "mistral"),
    configuration: .generalAssistant
)

let r1 = try await agent.chat("My name is Rafael.")
let r2 = try await agent.chat("What's my name?")  // Agent remembers
```

### Custom Tool

```swift
struct WeatherTool: Tool {
    let name = "get_weather"
    let description = "Returns current weather for a city."
    let parameters = JSONSchema.object(
        properties: ["city": .string("City name")],
        required: ["city"]
    )

    func execute(input: [String: Any]) async throws -> String {
        let city = input["city"] as? String ?? "unknown"
        return "Sunny, 22°C in \(city)"
    }
}

let agent = Agent(provider: OllamaProvider(), tools: [WeatherTool()])
```

### Logging Plugin

```swift
let agent = Agent(
    provider: OllamaProvider(),
    plugins: [LoggingPlugin()]
)
```

---

## Architecture

```
Agent (Actor)
├── AgentConfiguration
├── LLMProvider (Protocol)
│   ├── OllamaProvider     → OpenAICompatibleProvider
│   └── LlamaCppProvider   → OpenAICompatibleProvider
├── ToolRegistry (Actor)
│   └── Tool (Protocol)
│       ├── FilesystemTool
│       ├── ShellTool       (macOS only)
│       └── HTTPTool
├── MemoryStore (Protocol)
│   ├── ConversationMemory  (Sliding Window)
│   └── SummaryMemory       (LLM-based compression)
└── AgentOrchestrator       (ReAct Loop)
    └── AgentPlugin (Protocol)
        └── LoggingPlugin
```

---

## Run Tests

```bash
cd /path/to/SwiftAgent
swift test
```

---

## License

MIT

---

**Author:** [Rafael Yilmaz](https://github.com/9t29zhmwdh-coder) · **Status:** Framework Preview · **Last Updated:** June 2026
