import Foundation

struct LocalStorage: StorageProvider {
    private let root: URL
    private let fileManager: FileManager

    init(folder: String, fileManager: FileManager = .default) {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        self.root = paths[0].appendingPathComponent(folder)
        try? fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        self.fileManager = fileManager
    }

    func set(key: String, data: Data) async throws {
        let url = root.appendingPathComponent(key.toSafeFileName())
        try data.write(to: url, options: .atomic)
    }

    func get(key: String) async throws -> Data? {
        let url = root.appendingPathComponent(key.toSafeFileName())
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return try Data(contentsOf: url)
    }

    func delete(key: String) async throws {
        let url = root.appendingPathComponent(key.toSafeFileName())
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}

fileprivate extension String {
    func toSafeFileName() -> String {
        return Data(self.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_")
    }
}
