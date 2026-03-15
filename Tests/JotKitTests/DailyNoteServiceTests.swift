import Foundation
import Testing
@testable import JotKit

@Suite("DailyNoteService", .serialized)
struct DailyNoteServiceTests {

    @Test("Today's file URL uses yyyy-MM-dd.md format")
    func todayFileURLFormat() {
        let url = DailyNoteService.todayFileURL()
        let filename = url.lastPathComponent
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expected = formatter.string(from: Date()) + ".md"
        #expect(filename == expected)
    }

    @Test("Load returns empty string when file does not exist")
    func loadReturnsEmptyWhenMissing() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("jot-daily-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        Preferences.dailyNotesDirectory = tempDir.path

        let content = try DailyNoteService.load()
        #expect(content == "")
    }

    @Test("Load returns file content when file exists")
    func loadReturnsContentWhenExists() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("jot-daily-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        Preferences.dailyNotesDirectory = tempDir.path

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: Date()) + ".md"
        let fileURL = tempDir.appendingPathComponent(filename)
        try "Hello daily note".write(to: fileURL, atomically: true, encoding: .utf8)

        let content = try DailyNoteService.load()
        #expect(content == "Hello daily note")
    }

    @Test("Save creates directory and file")
    func saveCreatesDirectoryAndFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("jot-daily-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        Preferences.dailyNotesDirectory = tempDir.path

        try DailyNoteService.save(content: "Daily content")

        let url = DailyNoteService.todayFileURL()
        #expect(FileManager.default.fileExists(atPath: url.path))

        let saved = try String(contentsOf: url, encoding: .utf8)
        #expect(saved == "Daily content")
    }

    @Test("Save overwrites existing file")
    func saveOverwritesExistingFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("jot-daily-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        Preferences.dailyNotesDirectory = tempDir.path

        try DailyNoteService.save(content: "First version")
        try DailyNoteService.save(content: "Second version")

        let saved = try String(contentsOf: DailyNoteService.todayFileURL(), encoding: .utf8)
        #expect(saved == "Second version")
    }
}
