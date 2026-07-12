# Changelog

All notable changes to SwiftAgent will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.1.3] - 2026-07-13

### Fixed

- README.de.md was missing the "this is a library, not a standalone app" callout that README.md has right after the badge row.

## [0.1.2] - 2026-07-11

### Added

- Documented Dual-Licensing assessment (Community-only) in ROADMAP.md.

## [0.1.1] - 2026-07-10

### Fixed

- Fixed the test suite failing to compile entirely (inline `await` on an actor-isolated property inside `XCTAssertEqual`/`XCTAssertTrue`, and a missing `await` on the actor-isolated `Agent.runStream(_:)`); the same missing `await` also appeared in both READMEs' streaming example
- Fixed em-dashes across documentation files, including one remaining instance in README.md
- Fixed `CONTRIBUTING.md` referencing a nonexistent `SwiftAgent.xcodeproj` (this is a Swift Package)
- Corrected `ARCHITECTURE.md`'s file tree and design decisions to match the actual `Sources/SwiftAgent/` layout

### Changed

- CI now runs `swift test` in addition to `swift build`

## [0.1.0] - 2026-06-15

### Added

- ReAct agent loop (`AgentOrchestrator`): reason, act, observe cycle with a configurable `maxIterations` cutoff
- Streaming support (`runStream`, `AgentEvent`): text deltas, tool call start/finish, final result
- Tool system: `Tool` protocol, JSON Schema parameter definitions, OpenAI function-calling format, `ToolRegistry` actor
- Built-in tools: `FilesystemTool`, `HTTPTool`, `ShellTool` (macOS only)
- Memory: `ConversationMemory` (sliding window) and `SummaryMemory` (LLM-based summary compression)
- Plugin architecture (`AgentPlugin`): lifecycle hooks for logging, monitoring, tracing
- Ollama and llama.cpp backends via a shared `OpenAICompatibleProvider`
- Pure Foundation + URLSession implementation, no external dependencies
