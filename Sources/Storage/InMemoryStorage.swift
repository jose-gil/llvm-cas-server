import Foundation

actor InMemoryStorage: StorageProvider {
    private let cache = NSCache<NSString, NSData>()
    
    /// - Parameter limit: The maximum amount of memory allowed for the cache, specified in megabytes (MB).
    init(limit: Int) {
        self.cache.totalCostLimit = limit * 1024 * 1024
    }

    func set(key: String, data: Data) async {
        cache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
    }

    func get(key: String) async -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }

    func delete(key: String) async {
        cache.removeObject(forKey: key as NSString)
    }
}
