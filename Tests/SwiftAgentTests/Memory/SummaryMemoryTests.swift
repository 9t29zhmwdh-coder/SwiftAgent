import XCTest
@testable import SwiftAgent

final class SummaryMemoryTests: XCTestCase {

    func testAddAndRetrieveWithinWindow() async {
        let provider = MockLLMProvider()
        let memory = SummaryMemory(llmProvider: provider, recentWindowSize: 10, compressionBatchSize: 20)
        await memory.add(message: .user("Frage 1"))
        await memory.add(message: .assistant("Antwort 1"))
        let messages = await memory.retrieve()
        XCTAssertEqual(messages.filter { $0.role != .system }.count, 2)
    }

    func testSystemMessageHandling() async {
        let provider = MockLLMProvider()
        let memory = SummaryMemory(llmProvider: provider, recentWindowSize: 5)
        await memory.add(message: .system("Systemkontext"))
        await memory.add(message: .user("Frage"))
        let messages = await memory.retrieve()
        let systemMsgs = messages.filter { $0.role == .system }
        XCTAssertEqual(systemMsgs.first?.content, "Systemkontext")
    }

    func testClear() async {
        let provider = MockLLMProvider()
        let memory = SummaryMemory(llmProvider: provider, recentWindowSize: 5)
        await memory.add(message: .user("test"))
        await memory.clear()
        let count = await memory.count
        XCTAssertEqual(count, 0)
    }
}
