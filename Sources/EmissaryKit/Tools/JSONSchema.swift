import Foundation

public struct JSONSchema: Codable, Sendable, Equatable {
    public let type: String
    public let description: String?
    public let properties: [String: PropertyDefinition]?
    public let required: [String]?
    public let items: Box<JSONSchema>?

    public init(
        type: String = "object",
        description: String? = nil,
        properties: [String: PropertyDefinition]? = nil,
        required: [String]? = nil,
        items: JSONSchema? = nil
    ) {
        self.type = type
        self.description = description
        self.properties = properties
        self.required = required
        self.items = items.map(Box.init)
    }

    public static func object(
        description: String? = nil,
        properties: [String: PropertyDefinition],
        required: [String] = []
    ) -> JSONSchema {
        JSONSchema(
            type: "object",
            description: description,
            properties: properties,
            required: required.isEmpty ? nil : required
        )
    }
}

public struct PropertyDefinition: Codable, Sendable, Equatable {
    public let type: String
    public let description: String?
    public let enumValues: [String]?
    public let items: Box<JSONSchema>?

    public init(
        type: String,
        description: String? = nil,
        enumValues: [String]? = nil,
        items: JSONSchema? = nil
    ) {
        self.type = type
        self.description = description
        self.enumValues = enumValues
        self.items = items.map(Box.init)
    }

    public static func string(_ description: String? = nil) -> PropertyDefinition {
        PropertyDefinition(type: "string", description: description)
    }
    public static func integer(_ description: String? = nil) -> PropertyDefinition {
        PropertyDefinition(type: "integer", description: description)
    }
    public static func boolean(_ description: String? = nil) -> PropertyDefinition {
        PropertyDefinition(type: "boolean", description: description)
    }
    public static func stringEnum(_ values: [String], description: String? = nil) -> PropertyDefinition {
        PropertyDefinition(type: "string", description: description, enumValues: values)
    }

    enum CodingKeys: String, CodingKey {
        case type, description, items
        case enumValues = "enum"
    }
}

// Wrapper für rekursive Codable-Strukturen
public final class Box<T: Codable & Sendable & Equatable>: Codable, Sendable, Equatable {
    public let value: T
    public init(_ value: T) { self.value = value }
    public init(from decoder: Decoder) throws { value = try T(from: decoder) }
    public func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
    public static func == (lhs: Box<T>, rhs: Box<T>) -> Bool { lhs.value == rhs.value }
}
