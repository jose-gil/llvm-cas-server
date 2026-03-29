import Foundation

protocol CASBlobRepository: Sendable {
    func set(value: Data) async throws -> Data
    func get(key: Data) async throws -> Data?
}
