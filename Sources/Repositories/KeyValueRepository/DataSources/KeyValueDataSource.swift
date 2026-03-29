import Foundation

protocol KeyValueDataSource {
    func setValue(key: Data, value: Data) throws
    func getValue(key: Data) throws -> Data?
}
