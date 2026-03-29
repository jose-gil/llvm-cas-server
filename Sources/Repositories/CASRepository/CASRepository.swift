import Foundation
import CryptoKit

protocol CASRepository: Sendable {
    func set(value: Data) async throws -> Data
    func get(key: Data) async throws -> Data?
}

actor DiskCASRepository: CASRepository {
    let rootURL: URL
    let tmpURL: URL
    let objectsURL: URL
    
    init(rootPath: String) throws {
        self.rootURL = URL(fileURLWithPath: rootPath)
        self.tmpURL = rootURL.appendingPathComponent("tmp")
        self.objectsURL = rootURL.appendingPathComponent("objects")
        
        // Crear estructura inicial
        try FileManager.default.createDirectory(at: tmpURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: objectsURL, withIntermediateDirectories: true)
    }
    
    func set(value: Data) async throws -> Data {
        
        let digest = SHA256.hash(data: value)
        let key = Data(digest)
        let hashString = key.map { String(format: "%02x", $0) }.joined()
        
        let prefix = String(hashString.prefix(2))
        let folderURL = objectsURL.appendingPathComponent(prefix)
        let finalURL = folderURL.appendingPathComponent(hashString)
        
        if FileManager.default.fileExists(atPath: finalURL.path) {
            return key
        }
        
        let tempFileURL = tmpURL.appendingPathComponent(UUID().uuidString)
        try value.write(to: tempFileURL, options: .atomic)
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        if !FileManager.default.fileExists(atPath: finalURL.path) {
            try FileManager.default.moveItem(at: tempFileURL, to: finalURL)
        } else {
            try? FileManager.default.removeItem(at: tempFileURL)
        }
        
        return key
    }
    
    func get(key: Data) async throws -> Data? {
        let hashString = key.map { String(format: "%02x", $0) }.joined()
        let prefix = String(hashString.prefix(2))
        let fileURL = objectsURL.appendingPathComponent(prefix).appendingPathComponent(hashString)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return try Data(contentsOf: fileURL)
    }
}
