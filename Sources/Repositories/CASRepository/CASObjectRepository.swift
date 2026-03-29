import Foundation

protocol CASObjectRepository: Sendable {
    func set(data: Data, references: [Data]) async throws -> Data
    func get(key: Data) async throws -> (data: Data, references: [Data])?
}
