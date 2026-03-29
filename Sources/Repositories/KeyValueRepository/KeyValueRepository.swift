import Foundation

protocol KeyValueRepository: Sendable {
    func setValue(key: Data, value: Data) async throws
    func getValue(key: Data) async throws -> Data?
}
