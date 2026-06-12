import XCTest
@testable import SwiftAgent

final class ToolRegistryTests: XCTestCase {

    func testRegisterAndRetrieve() async {
        let registry = ToolRegistry()
        await registry.register(MockTool(name: "test_tool"))
        let retrieved = await registry.tool(named: "test_tool")
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.name, "test_tool")
    }

    func testUnregister() async {
        let registry = ToolRegistry()
        await registry.register(MockTool(name: "removable"))
        await registry.unregister(name: "removable")
        let retrieved = await registry.tool(named: "removable")
        XCTAssertNil(retrieved)
    }

    func testIsEmpty() async {
        let registry = ToolRegistry()
        XCTAssertTrue(await registry.isEmpty)
        await registry.register(MockTool())
        XCTAssertFalse(await registry.isEmpty)
    }

    func testToolDefinitions() async {
        let tools: [any Tool] = [
            MockTool(name: "tool_a"),
            MockTool(name: "tool_b"),
            MockTool(name: "tool_c")
        ]
        let registry = ToolRegistry(tools: tools)
        let defs = await registry.toolDefinitions
        XCTAssertEqual(defs.count, 3)
        let names = Set(defs.map { $0.function.name })
        XCTAssertEqual(names, Set(["tool_a", "tool_b", "tool_c"]))
    }

    func testExecuteSuccess() async throws {
        let tool = MockTool(name: "greeter", result: "Hallo Welt")
        let registry = ToolRegistry(tools: [tool])
        let toolCall = ToolCall(id: "tc1", function: .init(name: "greeter", arguments: "{\"input\":\"test\"}"))
        let result = try await registry.execute(toolCall: toolCall)
        XCTAssertEqual(result, "Hallo Welt")
    }

    func testExecuteNotFound() async {
        let registry = ToolRegistry()
        let toolCall = ToolCall(id: "tc1", function: .init(name: "nonexistent", arguments: "{}"))
        do {
            _ = try await registry.execute(toolCall: toolCall)
            XCTFail("Sollte einen Fehler werfen")
        } catch let error as ToolError {
            if case .notFound(let name) = error {
                XCTAssertEqual(name, "nonexistent")
            } else {
                XCTFail("Falscher ToolError-Typ")
            }
        } catch {
            XCTFail("Unerwarteter Fehler: \(error)")
        }
    }

    func testConcurrentRegistration() async {
        let registry = ToolRegistry()
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<50 {
                group.addTask { await registry.register(MockTool(name: "tool_\(i)")) }
            }
        }
        let count = await registry.allTools.count
        XCTAssertEqual(count, 50)
    }
}
