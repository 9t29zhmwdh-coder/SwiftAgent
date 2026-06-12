import Foundation

/// Führt HTTP-Anfragen aus, optional auf erlaubte Hosts beschränkt.
public struct HTTPTool: Tool {
    public let name = "http_request"
    public let description = "Führt HTTP GET/POST-Anfragen aus und gibt den Response-Body zurück."
    public let parameters = JSONSchema.object(
        properties: [
            "url": .string("Vollständige URL"),
            "method": .stringEnum(["GET", "POST", "PUT", "DELETE", "PATCH"], description: "HTTP-Methode"),
            "body": .string("Request-Body als JSON-String (optional)"),
            "headers": .string("HTTP-Header als JSON-Objekt (optional)")
        ],
        required: ["url", "method"]
    )

    private let allowedHosts: Set<String>?
    private let session: URLSession

    public init(allowedHosts: Set<String>? = nil, session: URLSession = .shared) {
        self.allowedHosts = allowedHosts
        self.session = session
    }

    public func execute(input: [String: Any]) async throws -> String {
        guard let urlString = input["url"] as? String,
              let url = URL(string: urlString) else {
            throw ToolError.invalidInput(toolName: name, message: "Ungültige URL")
        }

        if let allowed = allowedHosts, let host = url.host {
            guard allowed.contains(host) else {
                throw ToolError.permissionDenied(toolName: name)
            }
        }

        let method = input["method"] as? String ?? "GET"
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = method

        if let headersString = input["headers"] as? String,
           let headersData = headersString.data(using: .utf8),
           let headers = try? JSONSerialization.jsonObject(with: headersData) as? [String: String] {
            for (key, value) in headers { request.setValue(value, forHTTPHeaderField: key) }
        }

        if let body = input["body"] as? String {
            request.httpBody = body.data(using: .utf8)
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        let (data, response) = try await session.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let bodyString = String(data: data, encoding: .utf8) ?? "<binär>"
        return "HTTP \(statusCode)\n\(bodyString)"
    }
}
