import Foundation
import GRDB

final class GRDBKeyvalueDataSource: KeyvalueDataSource {
    private let dbQueue: DatabaseQueue
    
    init(path: String) throws {
        self.dbQueue = try DatabaseQueue(path: path)
        try setupDatabase()
    }
    
    // ActionCache is a key value storage can be used to associate two CASIDs.
    private func setupDatabase() throws {
        try dbQueue.write { db in
            try db.create(table: "action_cache") { t in
                t.primaryKey("action_key", .blob)
                t.column("value_data", .blob).notNull()
            }
        }
    }
    
    func setValue(key: Data, value: Data) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO action_cache (action_key, value_data) VALUES (?, ?)",
                arguments: [key, value]
            )
        }
    }
    
    func getValue(key: Data) throws -> Data? {
        return try dbQueue.read { db in
            let row = try Row.fetchOne(db, sql: "SELECT value_data FROM action_cache WHERE action_key = ?", arguments: [key])
            return row?["value_data"]
        }
    }
}
