# Privacy Policy

SwiftAgent is a Swift library. As a framework, it does not collect or transmit any data itself.
Privacy behavior depends entirely on the application that integrates SwiftAgent.

- **No built-in telemetry:** SwiftAgent contains no analytics, tracking, or reporting code.
- **LLM requests:** When your app uses SwiftAgent to call a local LLM (Ollama, llama.cpp), requests stay on-device. When calling a cloud LLM, that provider's privacy policy applies.
- **Memory module:** Any agent memory is stored in-process or wherever the host app chooses to persist it.

Integrators are responsible for disclosing AI usage to their end users.
