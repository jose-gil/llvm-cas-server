import Foundation

protocol StorageProvider {
    func set(key: String, data: Data) async throws
    func get(key: String) async throws -> Data?
    func delete(key: String) async throws
}
