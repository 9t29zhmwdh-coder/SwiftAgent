# Getting Started with SwiftAgent

SwiftAgent is a Swift Package Manager **library**, not a standalone app. This guide is for Swift developers who want to add it to their own Xcode project or Swift package and run their first agent call.

> **Requirements:** Swift 5.9+, macOS 13+ or iOS 16+, and either [Ollama](https://ollama.com) or a [llama.cpp server](https://github.com/ggerganov/llama.cpp) running locally.

---

## 1. Start a local model server

SwiftAgent talks to a model server over HTTP, it does not bundle or run a model itself.

**Option A: Ollama (recommended for a first try)**

1. Download and install [Ollama](https://ollama.com) for macOS.
2. Open a terminal and pull a small model:
   ```bash
   ollama pull llama3.2
   ```
3. Ollama runs in the background automatically after install and listens on port `11434`. Verify with:
   ```bash
   curl http://localhost:11434/api/tags
   ```
   If this prints JSON instead of a connection error, it's running.

**Option B: llama.cpp server**

Start `llama-server` with an OpenAI-compatible endpoint on port `8080`. See the [llama.cpp README](https://github.com/ggerganov/llama.cpp) for build and run instructions.

---

## 2. Add SwiftAgent to your project

**In Xcode:**

1. Open your project or workspace.
2. File → Add Package Dependencies…
3. Enter `https://github.com/9t29zhmwdh-coder/SwiftAgent` and choose a version rule (e.g. "Up to Next Major").
4. Add the `SwiftAgent` product to your app target.

**In a `Package.swift` for your own Swift package:**

```swift
dependencies: [
    .package(url: "https://github.com/9t29zhmwdh-coder/SwiftAgent", from: "1.0.0")
],
targets: [
    .target(name: "YourTarget", dependencies: ["SwiftAgent"])
]
```

Then run:

```bash
swift package resolve
```

---

## 3. Run your first agent call

With Ollama running from step 1, add this to any `async` context in your app:

```swift
import SwiftAgent

let agent = Agent.ollama(modelName: "llama3.2")
let result = try await agent.run("What is the Fibonacci sequence?")
print(result)
```

If you see a text response printed, everything is wired up correctly.

---

## 4. Next steps

- See the [README](README.md#quick-start) for tool use, streaming, multi-turn conversation and custom tool examples.
- See the [Architecture section](README.md#architecture) for how `Agent`, `ToolRegistry`, `MemoryStore` and `AgentOrchestrator` fit together.

## Something not working?

- `curl http://localhost:11434/api/tags` (Ollama) or the llama.cpp server's equivalent must succeed before any `Agent.run(...)` call will work, connection errors from SwiftAgent almost always mean the model server isn't reachable yet.
- Check [GitHub Issues](https://github.com/9t29zhmwdh-coder/SwiftAgent/issues) to see if someone already ran into the same problem, or open a new one with the exact error.
