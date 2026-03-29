import Foundation

actor DefaultKeyvalueRepository: KeyvalueRepository {
    private let cache: KeyvalueDataSource
    private let local: KeyvalueDataSource
    
    init(cache: KeyvalueDataSource, local: KeyvalueDataSource) {
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
