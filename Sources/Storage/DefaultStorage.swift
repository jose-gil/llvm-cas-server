import Foundation

final class DefaultStorage: StorageProvider {
    private let cache: StorageProvider
    private let local: StorageProvider

    /// - Parameter limit: The maximum amount of memory allowed for the cache, specified in megabytes (MB).
    init(limit: Int = 100, folder: String = "ServerData") {
        self.cache = InMemoryStorage(limit: limit)
        self.local = LocalStorage(folder: folder)
    }

    func set(key: String, data: Data) async throws {
        try await local.set(key: key, data: data)
        try await cache.set(key: key, data: data)
    }

    func get(key: String) async throws -> Data? {
        if let cached = try await cache.get(key: key) {
            return cached
        }
        
        if let persisted = try await local.get(key: key) {
            try await cache.set(key: key, data: persisted) // Re-cache
            return persisted
        }
        return nil
    }

    func delete(key: String) async throws {
        try await cache.delete(key: key)
        try await local.delete(key: key)
    }
}
