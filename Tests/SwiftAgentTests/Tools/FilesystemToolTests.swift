import XCTest
@testable import SwiftAgent

final class FilesystemToolTests: XCTestCase {

    var tempDir: URL!
    var tool: FilesystemTool!

    override func setUp() async throws {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("SwiftAgentTests_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        tool = FilesystemTool(allowedBasePath: tempDir)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testWriteAndRead() async throws {
        let path = tempDir.appendingPathComponent("test.txt").path
        let writeResult = try await tool.execute(input: [
            "action": "write_file", "path": path, "content": "Hallo SwiftAgent!"
        ])
        XCTAssertTrue(writeResult.contains("erfolgreich"))

        let readResult = try await tool.execute(input: ["action": "read_file", "path": path])
        XCTAssertEqual(readResult, "Hallo SwiftAgent!")
    }

    func testFileExists() async throws {
        let path = tempDir.appendingPathComponent("exists.txt").path
        let before = try await tool.execute(input: ["action": "file_exists", "path": path])
        XCTAssertEqual(before, "false")

        _ = try await tool.execute(input: ["action": "write_file", "path": path, "content": "x"])
        let after = try await tool.execute(input: ["action": "file_exists", "path": path])
        XCTAssertEqual(after, "true")
    }

    func testListDirectory() async throws {
        _ = try await tool.execute(input: ["action": "write_file", "path": tempDir.appendingPathComponent("a.txt").path, "content": "a"])
        _ = try await tool.execute(input: ["action": "write_file", "path": tempDir.appendingPathComponent("b.txt").path, "content": "b"])
        let result = try await tool.execute(input: ["action": "list_directory", "path": tempDir.path])
        XCTAssertTrue(result.contains("a.txt"))
        XCTAssertTrue(result.contains("b.txt"))
    }

    func testDeleteFile() async throws {
        let path = tempDir.appendingPathComponent("del.txt").path
        _ = try await tool.execute(input: ["action": "write_file", "path": path, "content": "x"])
        let deleteResult = try await tool.execute(input: ["action": "delete_file", "path": path])
        XCTAssertTrue(deleteResult.contains("gelöscht"))
        let exists = try await tool.execute(input: ["action": "file_exists", "path": path])
        XCTAssertEqual(exists, "false")
    }

    func testPermissionDenied() async {
        let outsidePath = "/tmp/outside_\(UUID().uuidString).txt"
        do {
            _ = try await tool.execute(input: ["action": "read_file", "path": outsidePath])
            XCTFail("Sollte PermissionDenied werfen")
        } catch let error as ToolError {
            if case .permissionDenied = error { return }
            XCTFail("Falscher ToolError-Typ: \(error)")
        } catch {
            XCTFail("Unerwarteter Fehler: \(error)")
        }
    }

    func testInvalidAction() async {
        do {
            _ = try await tool.execute(input: ["action": "invalid_action", "path": tempDir.path])
            XCTFail("Sollte InvalidInput werfen")
        } catch let error as ToolError {
            if case .invalidInput = error { return }
            XCTFail("Falscher ToolError-Typ")
        } catch {
            XCTFail("Unerwarteter Fehler: \(error)")
        }
    }
}
