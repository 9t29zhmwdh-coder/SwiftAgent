<div align="center">
  <img src="RayStudio.png" alt="RayStudio Logo" width="120"/>

  <h1>SwiftAgent</h1>
</div>

[🇩🇪 Deutsche Version](README.de.md)

[![CI](https://github.com/9t29zhmwdh-coder/SwiftAgent/actions/workflows/ci.yml/badge.svg)](https://github.com/9t29zhmwdh-coder/SwiftAgent/actions) ![Apple Silicon](https://img.shields.io/badge/Apple-Silicon-000000?logo=apple&logoColor=white) ![Platform](https://img.shields.io/badge/Platform-macOS_%7C_iOS-lightgrey?logo=apple&logoColor=black) ![Swift](https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white) ![AI | Claude Code](https://img.shields.io/badge/AI-Claude_Code-black?logo=anthropic&logoColor=white) ![AI | Copilot](https://img.shields.io/badge/AI-Copilot-black?logo=github&logoColor=white) ![AI | Ollama](https://img.shields.io/badge/AI-Ollama-black?logo=ollama&logoColor=white)

A lightweight, modular Swift agent framework for local LLMs; no external dependencies, pure Foundation + URLSession.

Works out of the box with **Ollama** (port 11434) and **llama.cpp** (port 8080) via their OpenAI-compatible APIs.

---

## Features

- **Zero external dependencies**: Foundation + URLSession only
- **Swift Concurrency**: async/await, actors, AsyncStream
- **ReAct Loop**: Reason → Act → Observe (multi-step tool use)
- **Streaming**: Server-Sent Events (SSE) with `AsyncThrowingStream`
- **Tool System**: JSON Schema, OpenAI function-calling format, built-in tools
- **Memory**: Sliding-window + LLM-based summary compression
- **Plugin Architecture**: Lifecycle hooks for logging, monitoring, tracing
- **macOS 13+ and iOS 16+**: single codebase, no platform-specific core

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
for try await event in await agent.runStream("Write a haiku about Swift") {
    switch event {
    case .textDelta(let chunk):
        print(chunk, terminator: "")
    case .toolCallStarted(let name, _):
        print("
[Tool: \(name)]")
    case .finished(let result):
        print("
Done: \(result)")
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

**Author:** [Rafael Yilmaz](https://github.com/9t29zhmwdh-coder) · **Status:** Active · ![version](https://img.shields.io/github/v/release/9t29zhmwdh-coder/SwiftAgent?color=6b7280&style=flat-square) · **License:** MIT
