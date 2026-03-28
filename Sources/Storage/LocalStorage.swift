import Foundation

struct LocalStorage: StorageProvider {
    private let rootURL: URL
    private let tempURL: URL    
    private let fileManager: FileManager

    init(folder: String, fileManager: FileManager = .default) throws {
//        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//        self.root = paths[0].appendingPathComponent(folder)
//        try? fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        
        self.rootURL = URL(fileURLWithPath: folder).appendingPathComponent("objects")
        self.tempURL = URL(fileURLWithPath: folder).appendingPathComponent("tmp")
        
        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true)
        
        self.fileManager = fileManager
    }

    func set(key: String, data: Data) async throws {
//        let url = root.appendingPathComponent(key.toSafeFileName())
//        try data.write(to: url, options: .atomic)
    }

    func get(key: String) async throws -> Data? {
//        let url = root.appendingPathComponent(key.toSafeFileName())
//        guard fileManager.fileExists(atPath: url.path) else { return nil }
//        return try Data(contentsOf: url)
        Data()
    }

    func delete(key: String) async throws {
//        let url = root.appendingPathComponent(key.toSafeFileName())
//        if fileManager.fileExists(atPath: url.path) {
//            try fileManager.removeItem(at: url)
//        }
    }
}

fileprivate extension String {
    func toSafeFileName() -> String {
        return Data(self.utf8).base64EncodedString().replacingOccurrences(of: "/", with: "_")
    }
}
