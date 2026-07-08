# Architecture

## Overview

SwiftAgent is a lightweight, modular Swift package providing a ReAct agent loop for local LLMs, using only Foundation and URLSession, no external dependencies.

```
Sources/SwiftAgent/
├── Agent/
│   ├── Agent.swift                  # Public actor facade (run, runStream, chat, clearMemory)
│   └── AgentConfiguration.swift     # Presets (default, codeAssistant, generalAssistant)
├── Orchestration/
│   ├── AgentOrchestrator.swift      # ReAct loop (run + runStream)
│   ├── AgentEvent.swift             # Streaming event enum (textDelta, toolCallStarted, finished, ...)
│   └── ReActStep.swift
├── LLM/
│   ├── LLMProvider.swift            # Backend protocol
│   ├── OllamaProvider.swift         # Ollama-specific defaults over OpenAICompatibleProvider
│   ├── LlamaCppProvider.swift       # llama.cpp-specific defaults over OpenAICompatibleProvider
│   ├── OpenAICompatibleProvider.swift
│   └── Models/                     # ChatMessage, ChatRequest, ChatResponse, StreamChunk
├── Tools/
│   ├── Tool.swift                   # Tool protocol
│   ├── ToolRegistry.swift           # Actor: register/execute tools
│   ├── ToolCall.swift
│   ├── JSONSchema.swift
│   └── BuiltIn/                     # FilesystemTool, HTTPTool, ShellTool (macOS only)
├── Memory/
│   ├── MemoryStore.swift            # Memory protocol
│   ├── ConversationMemory.swift     # Actor: sliding-window memory
│   └── SummaryMemory.swift          # Actor: LLM-based summary compression
└── Plugin/
    └── AgentPlugin.swift             # Lifecycle hook protocol (willCallLLM, didUseTool, ...)
```

## Design Decisions

- **No external dependencies**: pure Foundation + URLSession keeps binary size minimal and avoids SPM dependency conflicts for consumers.
- **Protocol-oriented**: `LLMProvider`, `Tool`, `MemoryStore`, and `AgentPlugin` are protocols; backends, tools, memory strategies, and plugins are all swappable and easy to mock in tests.
- **Actors for shared mutable state**: `Agent`, `ToolRegistry`, `ConversationMemory`, and `SummaryMemory` are actors, so concurrent tool execution and plugin notification cannot race on their internal state. `AgentOrchestrator` itself is a `Sendable` final class since it holds no mutable state of its own.
- **ReAct loop**: Reason, Act, Observe cycle in `AgentOrchestrator`, with a configurable `maxIterations` cutoff and a `runStream` variant that yields `AgentEvent`s (text deltas, tool call start/finish, final result) instead of returning only the final string.

## CI

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  build-and-test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v6
      - run: swift build
      - run: swift test
```
