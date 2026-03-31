import Foundation
import Crypto   

actor DiskCASObjectRepository: CASObjectRepository {
    private let rootURL: URL
    private let objectsURL: URL
    private let tmpURL: URL
    
    init(rootPath: String) throws {
        self.rootURL = URL(fileURLWithPath: rootPath)
        self.objectsURL = rootURL.appendingPathComponent("objects")
        self.tmpURL = rootURL.appendingPathComponent("tmp")
        
        try FileManager.default.createDirectory(at: objectsURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tmpURL, withIntermediateDirectories: true)
    }

    func set(data: Data, references: [Data]) async throws -> Data {
        let payload = encode(data: data, references: references)
        let digest = SHA256.hash(data: payload)
        let key = Data(digest)
        let hashString = key.map { String(format: "%02x", $0) }.joined()
        
        let prefix = String(hashString.prefix(2))
        let folderURL = objectsURL.appendingPathComponent(prefix)
        let finalURL = folderURL.appendingPathComponent(hashString)
        
        if FileManager.default.fileExists(atPath: finalURL.path) {
            return key
        }
        
        let tempFileURL = tmpURL.appendingPathComponent(UUID().uuidString)
        try payload.write(to: tempFileURL, options: .atomic)
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        if !FileManager.default.fileExists(atPath: finalURL.path) {
            try FileManager.default.moveItem(at: tempFileURL, to: finalURL)
        } else {
            try? FileManager.default.removeItem(at: finalURL)
            try FileManager.default.moveItem(at: tempFileURL, to: finalURL)
        }
        
        return key
    }
    
    func get(key: Data) async throws -> (data: Data, references: [Data])? {
        let hashString = key.map { String(format: "%02x", $0) }.joined()
        let prefix = String(hashString.prefix(2))
        let fileURL = objectsURL.appendingPathComponent(prefix).appendingPathComponent(hashString)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        guard let payload = try? Data(contentsOf: fileURL) else { return nil }
        
        return decode(payload: payload)
    }
}

extension DiskCASObjectRepository {
    
    private func encode(data: Data, references: [Data]) -> Data {
        var buffer = Data()
        
        let uniqueSortedRefs = Array(Set(references)).sorted { $0.lexicographicallyPrecedes($1) }
        
        var dataLen = UInt64(data.count).littleEndian
        buffer.append(withUnsafeBytes(of: &dataLen) { Data($0) })
        buffer.append(data)
        
        var refsCount = UInt64(uniqueSortedRefs.count).littleEndian
        buffer.append(withUnsafeBytes(of: &refsCount) { Data($0) })
        
        for ref in uniqueSortedRefs {
            buffer.append(ref)
        }
        
        return buffer
    }
    
    private func decode(payload: Data) -> (data: Data, references: [Data])? {
        var offset = 0
        let uint64Size = MemoryLayout<UInt64>.size
        
        guard payload.count >= offset + uint64Size else { return nil }
        let dataLen = payload.subdata(in: offset..<offset + uint64Size).withUnsafeBytes {
            $0.load(as: UInt64.self).littleEndian
        }
        offset += uint64Size
        
        guard payload.count >= offset + Int(dataLen) else { return nil }
        let data = payload.subdata(in: offset..<offset + Int(dataLen))
        offset += Int(dataLen)
        
        guard payload.count >= offset + uint64Size else { return nil }
        let refsCount = payload.subdata(in: offset..<offset + uint64Size).withUnsafeBytes {
            $0.load(as: UInt64.self).littleEndian
        }
        offset += uint64Size
        
        var references: [Data] = []
        let refSize = 32
        
        for _ in 0..<Int(refsCount) {
            guard payload.count >= offset + refSize else {
                return nil
            }
            references.append(payload.subdata(in: offset..<offset + refSize))
            offset += refSize
        }
        
        return (data, references)
    }
}
