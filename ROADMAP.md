# Roadmap

## v0.1.0, Initial Release (2026-06-15)

- ReAct loop engine (`AgentOrchestrator`), reason, act, observe cycle
- Streaming response support (`runStream`, `AgentEvent`)
- Tool calling protocol, JSON Schema, `ToolRegistry` actor, built-in tools (`FilesystemTool`, `HTTPTool`, `ShellTool`)
- Memory module: sliding-window (`ConversationMemory`) and LLM-based summary compression (`SummaryMemory`)
- Plugin architecture (`AgentPlugin`) for logging, monitoring, tracing
- Ollama and llama.cpp backends, plus a public `OpenAICompatibleProvider` for any OpenAI-compatible endpoint
- Async/await throughout, pure Foundation + URLSession, no external dependencies

## v0.2.0, Planned

- [ ] Persistent memory (SQLite-backed `MemoryStore` implementation)
- [ ] Multi-agent orchestration (coordinating more than one `Agent` on a shared task)
- [ ] Resolve the remaining experimental-StrictConcurrency `@Sendable` capture warnings in `AgentOrchestrator.notifyPlugins` ahead of adopting full Swift 6 language mode

## v0.3.0, Planned

- [ ] SwiftUI status view component
- [ ] Full test coverage for the `LLM/` and `Tools/BuiltIn/` layers (currently covered indirectly via mocks; add direct integration tests against a real local Ollama instance)

## v1.0.0, Stable

- [ ] Swift Package Index listing
- [ ] Comprehensive documentation site (DocC)

## Dual-Licensing Readiness

Assessed 2026-07-11: Community-only, not a Dual-Licensing candidate. SwiftAgent is a developer library/SDK (Swift Package Manager dependency, not a standalone app), the same category as agent frameworks like LangChain, AutoGen and CrewAI, which conventionally stay fully open source to maximize adoption. Its planned v1.0.0 distribution channel (Swift Package Index) is a standard package registry listing, not a licensing split. Revisit only if a genuine hosted/managed-service offering is built around it.
