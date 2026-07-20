# Changelog

All notable changes to SwiftAgent will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.1] - 2026-07-20

### Changed

- OpenSSF Scorecard workflow and badge.
- `copilot-instructions.md` for consistent AI-assisted contributions.
- Coverage reporting in CI (swift test --enable-code-coverage), pinned the checkout action.
- Unified the EN/DE language-switch link format.
- SECURITY.md now lists 1.0.x as the supported version instead of the stale 0.1.x.
- Split the README's security/CI badges onto their own line, separate from the platform/tech/AI badges (they were rendering as a single merged line).

## [1.0.0] - 2026-07-17

First stable release. As a Swift Package Manager library (not a
standalone app), its distribution *is* the versioned git tag itself:
consumers add `.package(url: ..., from: "1.0.0")` to their own
`Package.swift`, there is no separate installer or binary to build.
CI already builds and tests the package on every push, so this tag
marks the point where that continuously-verified library is
considered stable per this portfolio's own SemVer discipline.

## [0.1.4] - 2026-07-17

### Changed
- CI: added an explicit `permissions: contents: read` block to the workflow(s) that were missing one (CodeQL `actions/missing-workflow-permissions`), narrowing the default GITHUB_TOKEN scope.

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
