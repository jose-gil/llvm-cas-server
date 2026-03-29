import Foundation

actor DefaultKeyValueRepository: KeyValueRepository {
    private let cache: KeyValueDataSource
    private let local: KeyValueDataSource
    
    init(cache: KeyValueDataSource, local: KeyValueDataSource) {
        self.cache = cache
        self.local = local
    }
    
    func setValue(key: Data, value: Data) throws {
        try cache.setValue(key: key, value: value)
        try local.setValue(key: key, value: value)
    }
    
    func getValue(key: Data) throws -> Data? {
        if let value = try cache.getValue(key: key) {
            return value
        }
        
        return try local.getValue(key: key)
    }
}
