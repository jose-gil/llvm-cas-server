import Foundation
import GRDB

final class ActionCacheDatabaseStorage {
    private let dbQueue: DatabaseQueue
    
    init(path: String) throws {
        self.dbQueue = try DatabaseQueue(path: path)
        try setupDatabase()
    }
    
    // ActionCache is a key value storage can be used to associate two CASIDs.
    private func setupDatabase() throws {
        try dbQueue.write { db in
            try db.execute(sql: """
                    CREATE TABLE IF NOT EXISTS action_cache (
                        action_key BLOB PRIMARY KEY,
                        value_data BLOB NOT NULL
                    )
                """)
        }
    }
    
    func putValue(key: Data, value: Data) throws {
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
