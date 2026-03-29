import Foundation

protocol KeyvalueRepository: Sendable {
    func setValue(key: Data, value: Data) async throws
    func getValue(key: Data) async throws -> Data?
}
