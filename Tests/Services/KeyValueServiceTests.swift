import Foundation
import Testing
@testable import Server

@MainActor
final class MockKeyValueRepository: KeyValueRepository {
    var keyMock: Data!
    var valueMock: Data!
    var resultMock: Data!
    
    func setValue(key: Data, value: Data) async throws {
        keyMock = key
        valueMock = value
    }
    
    func getValue(key: Data) async throws -> Data? {
        keyMock = key
        return resultMock
    }
}

@MainActor
struct KeyValueServiceTests {
    let sut: KeyValueService
    let repository: MockKeyValueRepository
    
    init() {
        repository = MockKeyValueRepository()
        sut = KeyValueService(repository: repository)
    }
    
    @Test func getValue_success() async throws {
        let key = Data("key".utf8)
        let value: CompilationCacheService_Keyvalue_V1_Value = .with {
            $0.entries = ["key": Data("value".utf8)]
        }
        let request: CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.GetValue.Input = .with {
            $0.key = key
        }
        repository.resultMock = try value.serializedData()
        
        let result = try await sut.getValue(request: request, context: .stub)
        
        #expect(repository.keyMock == key)
        #expect(try result.value == value)
    }
    
    @Test func getValue_failure() async throws {
        let key = Data("key".utf8)
        let request: CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.GetValue.Input = .with {
            $0.key = key
        }
        repository.resultMock = nil
        
        let result = try await sut.getValue(request: request, context: .stub)
        
        #expect(repository.keyMock == key)
        #expect(try result.outcome == CompilationCacheService_Keyvalue_V1_GetValueResponse.Outcome.keyNotFound)
    }
    
    @Test func putValue_success() async throws {
        let key = Data("key".utf8)
        let value: CompilationCacheService_Keyvalue_V1_Value = .with {
            $0.entries = ["key": Data("value".utf8)]
        }
        let request: CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.PutValue.Input = .with {
            $0.key = key
            $0.value = value
        }
        
        let result = try await sut.putValue(request: request, context: .stub)
        
        #expect(!result.hasError)
        #expect(try repository.valueMock == value.serializedData())
        #expect(repository.keyMock == key)
    }
}
