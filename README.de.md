<div align="center">
  <img src="RayStudio.png" alt="RayStudio Logo" width="120"/>

  <h1>EmissaryKit</h1>
</div>

[🇬🇧 English Version](README.md)

[![CI](https://github.com/9t29zhmwdh-coder/EmissaryKit/actions/workflows/ci.yml/badge.svg)](https://github.com/9t29zhmwdh-coder/EmissaryKit/actions) [![CodeQL](https://github.com/9t29zhmwdh-coder/EmissaryKit/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/9t29zhmwdh-coder/EmissaryKit/security/code-scanning) [![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/9t29zhmwdh-coder/EmissaryKit/badge)](https://securityscorecards.dev/viewer/?uri=github.com/9t29zhmwdh-coder/EmissaryKit) [![OpenSSF Best Practices](https://www.bestpractices.dev/projects/13683/badge)](https://www.bestpractices.dev/projects/13683)

![Apple Silicon](https://img.shields.io/badge/Apple-Silicon-000000?logo=apple&logoColor=white) ![Platform](https://img.shields.io/badge/Platform-macOS_%7C_iOS-lightgrey?logo=apple&logoColor=black) ![Swift](https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white) ![AI | Claude Code](https://img.shields.io/badge/AI-Claude_Code-black?logo=anthropic&logoColor=white) ![AI | Copilot](https://img.shields.io/badge/AI-Copilot-black?logo=github&logoColor=white) ![AI | Ollama](https://img.shields.io/badge/AI-Ollama-black?logo=ollama&logoColor=white)

**Lässt ein lokales Sprachmodell etwas tun, nicht nur antworten.**

Wer Ollama selbst aufruft, bekommt Text zurück. EmissaryKit gibt dem Modell
Werkzeuge, die es selbst einsetzen kann, und dreht die Schleife bis die Aufgabe
erledigt ist:

```swift
let agent = Agent(
    provider: OllamaProvider(modelName: "llama3.2"),
    tools: [FilesystemTool(allowedBasePath: URL(fileURLWithPath: "/tmp"))]
)

try await agent.run("Lies /tmp/notizen.txt und fasse es zusammen.")
```

Das Modell liest daraus zwei Schritte: Datei öffnen, dann zusammenfassen. Es
ruft das Werkzeug auf, bekommt den Inhalt und schreibt die Zusammenfassung. Du
hast für nichts davon Ablauflogik geschrieben.

Alles läuft gegen ein Modell auf deinem Gerät. Nichts wird irgendwohin gesendet.

**Nichts für dich, wenn** ein Prompt und eine Antwort schon reichen: dann rufst
du den Endpoint selbst auf, das sind ein Dutzend Zeilen ohne Abhängigkeit. Der
vollständige Vergleich steht weiter unten.

> ℹ️ Eine Swift-Package-Manager-Bibliothek zum Einbetten ins eigene Projekt,
> keine App. Es gibt nichts separat zu installieren und zu starten.

---

## Warum nicht einfach die API selbst aufrufen

Für eine einzelne Frage: mach das. Das hier brauchst du, sobald das Modell
*handeln* soll:

| Du willst | Ohne Framework | Mit EmissaryKit |
|---|---|---|
| das Modell liest eine Datei, dann antwortet es | Antwort parsen, raten was gemeint war, die richtige Funktion rufen, Ergebnis zurückgeben, wiederholen | Werkzeug übergeben, `run` aufrufen |
| Ausgabe während sie entsteht | Server-Sent-Event-Strom von Hand zerlegen | `for try await event in agent.runStream(...)` |
| ein Gespräch länger als das Kontextfenster | selbst entscheiden was wegfällt | gleitendes Fenster, oder Zusammenfassung des Weggefallenen |
| verhindern, dass das Modell die falschen Dateien anfasst | Absicherung selbst schreiben | `FilesystemTool(allowedBasePath:)` |

Drei Werkzeuge sind dabei: Dateisystem, HTTP und Shell unter macOS. Jedes bekommt
seine Grenzen bei der Erzeugung, ein Werkzeug kann also nicht über das
hinausgreifen, was du erlaubt hast.

Die ganze Bibliothek sind rund 1300 Zeilen Swift und zieht nichts ausser
Foundation und URLSession herein.

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
import EmissaryKit

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
for try await event in await agent.runStream("Schreibe ein Haiku über Swift") {
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

## Deinstallation / Aufräumen

EmissaryKit ist eine Library, kein installiertes Programm: entferne es aus den `Package.swift`-Dependencies deiner Host-App (und lösche den aufgelösten Eintrag in `Package.resolved`), damit ist es weg. EmissaryKit selbst schreibt keine Dateien, keine `UserDefaults` und keine Keychain-Einträge; `FilesystemTool` fasst nur Pfade an, die deine eigene App ihm explizit über `allowedBasePath` übergibt. Jegliches Konversations-Memory lebt nur im Prozess deiner App und verschwindet, wenn diese beendet wird.

---

## Tests ausführen

```bash
cd /path/to/EmissaryKit
swift test
```

---

**Autor:** [Rafael Yilmaz](https://github.com/9t29zhmwdh-coder) · **Status:** Active · ![version](https://img.shields.io/github/v/release/9t29zhmwdh-coder/EmissaryKit?color=6b7280&style=flat-square) · **Lizenz:** MIT

