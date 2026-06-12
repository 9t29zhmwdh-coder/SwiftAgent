import Foundation

/// Lese/Schreib-Zugriff auf das Dateisystem, auf einen erlaubten Basispfad beschränkt.
public struct FilesystemTool: Tool {
    public let name = "filesystem"
    public let description = "Liest, schreibt, listet und löscht Dateien und Verzeichnisse."
    public let parameters = JSONSchema.object(
        properties: [
            "action": .stringEnum(
                ["read_file", "write_file", "list_directory", "file_exists", "delete_file", "create_directory"],
                description: "Auszuführende Aktion"
            ),
            "path": .string("Absoluter Dateipfad"),
            "content": .string("Dateiinhalt (nur für write_file)")
        ],
        required: ["action", "path"]
    )

    private let allowedBasePath: URL?

    public init(allowedBasePath: URL? = nil) {
        self.allowedBasePath = allowedBasePath
    }

    public func execute(input: [String: Any]) async throws -> String {
        guard let action = input["action"] as? String,
              let path = input["path"] as? String else {
            throw ToolError.invalidInput(toolName: name, message: "action und path sind Pflichtfelder")
        }

        if let base = allowedBasePath {
            let resolved = URL(fileURLWithPath: path).standardized.path
            let base = base.standardized.path
            guard resolved.hasPrefix(base) else {
                throw ToolError.permissionDenied(toolName: name)
            }
        }

        let fm = FileManager.default

        switch action {
        case "read_file":
            guard fm.fileExists(atPath: path) else {
                throw ToolError.executionFailed(
                    toolName: name,
                    underlying: NSError(domain: "FilesystemTool", code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Datei nicht gefunden: \(path)"])
                )
            }
            return try String(contentsOfFile: path, encoding: .utf8)

        case "write_file":
            guard let content = input["content"] as? String else {
                throw ToolError.invalidInput(toolName: name, message: "content fehlt für write_file")
            }
            let url = URL(fileURLWithPath: path)
            try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try content.write(to: url, atomically: true, encoding: .utf8)
            return "Datei erfolgreich geschrieben: \(path)"

        case "list_directory":
            let items = try fm.contentsOfDirectory(atPath: path)
            return items.sorted().joined(separator: "\n")

        case "file_exists":
            return fm.fileExists(atPath: path) ? "true" : "false"

        case "delete_file":
            try fm.removeItem(atPath: path)
            return "Datei erfolgreich gelöscht: \(path)"

        case "create_directory":
            try fm.createDirectory(atPath: path, withIntermediateDirectories: true)
            return "Verzeichnis erstellt: \(path)"

        default:
            throw ToolError.invalidInput(toolName: name, message: "Unbekannte Aktion: \(action)")
        }
    }
}
