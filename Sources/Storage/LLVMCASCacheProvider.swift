//import Foundation
//import CryptoKit
//
///// Representa el contenido de un objeto en el CAS,
///// emulando la estructura de LLVM con datos y referencias a otros objetos.
//struct CASObject: Codable {
//    let data: Data
//    let references: [String] // IDs de otros objetos (árbol de dependencias)
//}
//
///// Actor que garantiza que las operaciones de lectura/escritura
///// en la caché sean seguras entre múltiples hilos.
//actor LLVMCASCacheProvider {
//    
//    private let fileManager = FileManager.default
//    private let rootURL: URL
//    private let tempURL: URL
//    
//    enum CASError: Error {
//        case objectNotFound
//        case writeError(String)
//        case serializationError
//    }
//
//    init(storagePath: String) throws {
//        self.rootURL = URL(fileURLWithPath: storagePath).appendingPathComponent("objects")
//        self.tempURL = URL(fileURLWithPath: storagePath).appendingPathComponent("tmp")
//        
//        // Crear estructura de directorios profesional
//        try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
//        try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true)
//    }
//
//    // MARK: - API Pública (Equivalente a C++)
//
//    /// Guarda datos y referencias devolviendo un ID único basado en el contenido (CASPut)
//    func put(data: Data, references: [String] = []) async throws -> String {
//        let id = computeID(data: data, refs: references)
//        let object = CASObject(data: data, references: references)
//        
//        // Evitamos escribir si el objeto ya existe (Deduplicación)
//        let objectURL = urlForID(id)
//        if fileManager.fileExists(atPath: objectURL.path) {
//            return id
//        }
//
//        // Escritura atómica: Escribir en temp y luego mover (como LLVM)
//        let tempFileURL = tempURL.appendingPathComponent(UUID().uuidString)
//        let encoded = try JSONEncoder().encode(object)
//        
//        try encoded.write(to: tempFileURL, options: .atomic)
//        try fileManager.moveItem(at: tempFileURL, to: objectURL)
//        
//        return id
//    }
//
//    /// Recupera un objeto y opcionalmente lo extrae a un archivo temporal (CASGet/Load)
//    func get(id: String, writeToDisk: Bool = false) async throws -> (data: Data, refs: [String], path: String?) {
//        let objectURL = urlForID(id)
//        
//        guard let rawData = fileManager.contents(atPath: objectURL.path),
//              let object = try? JSONDecoder().decode(CASObject.self, from: rawData) else {
//            throw CASError.objectNotFound
//        }
//
//        if writeToDisk {
//            // Emula el "%%%%%%.blob" creando un archivo único para herramientas externas
//            let exportURL = tempURL.appendingPathComponent("\(UUID().uuidString).blob")
//            try object.data.write(to: exportURL)
//            return (object.data, object.references, exportURL.path)
//        }
//
//        return (object.data, object.references, nil)
//    }
//
//    // MARK: - Lógica Interna de Producción
//
//    /// Genera un hash SHA256 combinando contenido y referencias.
//    /// Esto asegura que si una dependencia cambia, el ID del padre también cambie.
//    private func computeID(data: Data, refs: [String]) -> String {
//        var hasher = SHA256()
//        hasher.update(data: data)
//        for ref in refs.sorted() { // Ordenamos para que el hash sea determinista
//            if let refData = ref.data(using: .utf8) {
//                hasher.update(data: refData)
//            }
//        }
//        return hasher.finalize().compactMap { String(format: "%02x", $0) }.joined()
//    }
//
//    /// Implementa una estructura de carpetas tipo Git/LLVM (sharding)
//    /// Ejemplo: id "a7b39..." -> objects/a7/b39...
//    private func urlForID(_ id: String) -> URL {
//        let prefix = String(id.prefix(2))
//        let folder = rootURL.appendingPathComponent(prefix)
//        
//        // En producción, crearíamos el subdirectorio bajo demanda
//        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
//        return folder.appendingPathComponent(id)
//    }
//}
