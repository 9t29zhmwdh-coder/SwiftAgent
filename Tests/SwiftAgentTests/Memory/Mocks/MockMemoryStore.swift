import Foundation
@testable import SwiftAgent

actor MockMemoryStore: MemoryStore {
    private var messages: [ChatMessage] = []
    var addCallCount: Int = 0
    var retrieveCallCount: Int = 0

    func add(message: ChatMessage) {
        addCallCount += 1
        messages.append(message)
    }

    func retrieve() -> [ChatMessage] {
        retrieveCallCount += 1
        return messages
    }

    func clear() { messages.removeAll() }

    var count: Int { messages.count }

    func setMessages(_ msgs: [ChatMessage]) { messages = msgs }
}
