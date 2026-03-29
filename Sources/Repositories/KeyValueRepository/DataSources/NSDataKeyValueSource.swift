import Foundation

final class NSDataKeyValueSource: KeyValueDataSource {
    private let cache = NSCache<NSData, NSData>()
    
    /// - Parameter limit: The maximum amount of memory allowed for the cache, specified in megabytes (MB).
    init(limit: Int) {
        self.cache.totalCostLimit = limit * 1024 * 1024
    }

    func setValue(key: Data, value: Data) throws {
        cache.setObject(value as NSData, forKey: key as NSData, cost: value.count)
    }
    
    func getValue(key: Data) throws -> Data? {
        cache.object(forKey: key as NSData) as? Data
    }
}
