# Architecture

## Overview

SwiftAgent is a lightweight, modular Swift package providing a ReAct agent loop
for local LLMs, using only Foundation and URLSession — no external dependencies.

```
Sources/SwiftAgent/
├── Agent.swift           # Main agent loop (ReAct)
├── Memory/
│   ├── MemoryProtocol.swift
│   └── InProcessMemory.swift
├── Tools/
│   ├── ToolProtocol.swift
│   └── ToolRegistry.swift
├── Backends/
│   ├── LLMBackendProtocol.swift
│   ├── OllamaBackend.swift
│   └── LlamaCppBackend.swift
└── Models/
    ├── Message.swift
    └── ToolCall.swift
```

## Design Decisions

- **No external dependencies:** Pure Foundation keeps binary size minimal and avoids SPM conflicts.
- **Protocol-oriented:** Backends and tools are protocols — easy to mock and extend.
- **ReAct loop:** Reason → Act → Observe cycle, configurable max iterations and stop conditions.

## CI

```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - run: swift build
      - run: swift test
```
