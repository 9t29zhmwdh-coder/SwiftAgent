import XCTest
@testable import SwiftAgent

final class ConversationMemoryTests: XCTestCase {

    func testAddAndRetrieve() async {
        let memory = ConversationMemory(windowSize: 10)
        await memory.add(message: .user("Hallo"))
        await memory.add(message: .assistant("Hi!"))
        let messages = await memory.retrieve()
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages[0].content, "Hallo")
        XCTAssertEqual(messages[1].content, "Hi!")
    }

    func testSlidingWindowTruncation() async {
        let memory = ConversationMemory(windowSize: 3)
        for i in 1...6 {
            await memory.add(message: .user("Nachricht \(i)"))
        }
        let messages = await memory.retrieve()
        XCTAssertEqual(messages.count, 3)
        XCTAssertEqual(messages.last?.content, "Nachricht 6")
    }

    func testSystemPromptAlwaysRetained() async {
        let memory = ConversationMemory(windowSize: 2)
        await memory.add(message: .system("System-Prompt"))
        for i in 1...5 {
            await memory.add(message: .user("User \(i)"))
        }
        let messages = await memory.retrieve()
        XCTAssertTrue(messages.contains { $0.role == .system })
        XCTAssertEqual(messages.filter { $0.role == .user }.count, 2)
    }

    func testClear() async {
        let memory = ConversationMemory()
        await memory.add(message: .user("test"))
        await memory.clear()
        let count = await memory.count
        XCTAssertEqual(count, 0)
    }

    func testRetrieveLast() async {
        let memory = ConversationMemory(windowSize: 20)
        for i in 1...10 {
            await memory.add(message: .user("Nachricht \(i)"))
        }
        let last3 = await memory.retrieveLast(3)
        XCTAssertEqual(last3.count, 3)
        XCTAssertEqual(last3.last?.content, "Nachricht 10")
    }
}
