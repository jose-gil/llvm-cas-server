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
        
        let key = Data(SHA256.hash(data: payload))
        let hexName = key.map { String(format: "%02x", $0) }.joined()
        
        let folderURL = objectsURL.appendingPathComponent(String(hexName.prefix(2)))
        let fileURL = folderURL.appendingPathComponent(hexName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) { return key }
        
        let tempURL = tmpURL.appendingPathComponent(UUID().uuidString)
        try payload.write(to: tempURL, options: .atomic)
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        try FileManager.default.moveItem(at: tempURL, to: fileURL)
        
        return key
    }
    
    func get(key: Data) async throws -> (data: Data, references: [Data])? {
        let hexName = key.map { String(format: "%02x", $0) }.joined()
        let fileURL = objectsURL
            .appendingPathComponent(String(hexName.prefix(2)))
            .appendingPathComponent(hexName)
        
        guard let payload = try? Data(contentsOf: fileURL) else { return nil }
        
        return decode(payload: payload)
    }
}

extension DiskCASObjectRepository {
    private func encode(data: Data, references: [Data]) -> Data {
        var buffer = Data()
        
        var dataLen = UInt64(data.count).littleEndian
        buffer.append(withUnsafeBytes(of: &dataLen) { Data($0) })
        buffer.append(data)
        
        var refsCount = UInt64(references.count).littleEndian
        buffer.append(withUnsafeBytes(of: &refsCount) { Data($0) })
        
        for ref in references {
            buffer.append(ref)
        }
        
        return buffer
    }
    
    private func decode(payload: Data) -> (data: Data, references: [Data])? {
        var offset = 0
        
        let dataLenSize = MemoryLayout<UInt64>.size
        guard payload.count >= offset + dataLenSize else { return nil }
        let dataLen = payload.subdata(in: offset..<offset+dataLenSize).withUnsafeBytes {
            $0.load(as: UInt64.self).littleEndian
        }
        offset += dataLenSize
        
        guard payload.count >= offset + Int(dataLen) else { return nil }
        let data = payload.subdata(in: offset..<offset+Int(dataLen))
        offset += Int(dataLen)
        
        guard payload.count >= offset + dataLenSize else { return nil }
        let refsCount = payload.subdata(in: offset..<offset+dataLenSize).withUnsafeBytes {
            $0.load(as: UInt64.self).littleEndian
        }
        offset += dataLenSize
        
        var references: [Data] = []
        for _ in 0..<Int(refsCount) {
            guard payload.count >= offset + 32 else { break }
            references.append(payload.subdata(in: offset..<offset+32))
            offset += 32
        }
        
        return (data, references)
    }
}
