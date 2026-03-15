import Foundation

public enum DailyNoteService {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    public static func todayFileURL() -> URL {
        let filename = dateFormatter.string(from: Date()) + ".md"
        return URL(fileURLWithPath: Preferences.dailyNotesDirectory)
            .appendingPathComponent(filename)
    }

    public static func load() throws -> String {
        let url = todayFileURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    public static func save(content: String) throws {
        let url = todayFileURL()
        let directory = url.deletingLastPathComponent().path

        try FileManager.default.createDirectory(
            atPath: directory, withIntermediateDirectories: true
        )

        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}
