import Foundation

protocol KeyvalueDataSource {
    func setValue(key: Data, value: Data) throws
    func getValue(key: Data) throws -> Data?
}
