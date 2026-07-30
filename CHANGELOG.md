# Changelog

All notable changes to EmissaryKit, formerly SwiftAgent, will be documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.2.0] - 2026-07-30

### Changed

- Renamed from SwiftAgent to EmissaryKit. Two actively maintained Swift agent frameworks carry the old name on GitHub, one with 219 stars and one with 98, both describing themselves the same way this package does. The collision was in the same category on the same platform, not merely a similar word.
- The Swift module is renamed with it, so `import SwiftAgent` becomes `import EmissaryKit`. Anything depending on this package has to change that line and the product name in its `Package.swift`.

---

## [1.1.4] - 2026-07-29

### Security

- The release workflow no longer grants `contents: write` for its whole run. The permission moves to the one job that publishes the release, and everything else runs with `contents: read`. OpenSSF Scorecard scores the Token-Permissions check 0 out of 10 whenever any workflow holds a top-level write permission, regardless of how little of the run needs it, so this single line was what held the check at zero.

---

## [1.1.3] - 2026-07-29

### Added

- `.github/workflows/release.yml`. Pushing a version tag produced nothing here: the tag landed in the repository and no release was ever created, which is how several versions ended up tagged but unreleased. The gap only showed when the tag list was compared against the release list. This package builds a library rather than an executable, so the workflow ships no artifact and takes the release notes from the matching `CHANGELOG.md` section, which keeps them from being maintained separately from the file.

---

## [1.1.2] - 2026-07-29

### Changed

Dependency and workflow updates merged since 1.1.1:

- chore(ci): bump the actions group with 3 updates

---

## [1.1.1] - 2026-07-29

### Changed

- CodeQL moved from GitHub's default setup to an advanced setup with a committed `.github/workflows/codeql.yml`. The default setup decides on its own when to run and skips pull requests that touch no code of a given language, so a dependency pull request changing only a manifest reported `skipping` on the required `Analyze (actions)` and `Analyze (swift)` checks and could never be merged. The workflow runs on every pull request regardless of what changed and uses the `security-extended` query suite, which the default setup does not allow choosing. Swift runs on a macOS runner with `build-mode: autobuild` because it needs a real compile; `actions` is a scanned-file language and stays on Linux. Required checks are unchanged.
- `.github/dependabot.yml` now groups updates per ecosystem and carries the `chore(ci)` and `chore(deps)` commit prefixes, matching the rest of the portfolio. Without grouping every single dependency opened its own pull request. The Swift group is limited to `minor` and `patch`, so a major bump cannot land inside a grouped pull request that reads as routine.

---

## [1.1.0] - 2026-07-24

### Added

- `OpenAICompatibleProvider`, `OllamaProvider` and `LlamaCppProvider` now accept `temperature`/`maxTokens` and forward them to the request body.
- `Agent.ollama(...)` and `Agent.llamaCpp(...)` now pass `configuration.temperature`/`configuration.maxTokens` down to the provider they create, closing a gap where both settings were accepted but silently never reached the LLM request.

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
