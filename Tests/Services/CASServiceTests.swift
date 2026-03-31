import Foundation
import Testing
@testable import Server

@MainActor
final class MockCASBlobRepository: CASBlobRepository {
    var keyMock: Data!
    var valueMock: Data!
        
    func set(value: Data) async throws -> Data {
        valueMock = value
        return keyMock
    }
    
    func get(key: Data) async throws -> Data? {
        keyMock = key
        return valueMock
    }
}

actor MockCASObjectRepository : CASObjectRepository {
    var keyMock: Data!
    var dataMock: Data!
    var referencesMock: [Data]!
    
    func set(data: Data, references: [Data]) async throws -> Data {
        dataMock = data
        referencesMock = references
        return keyMock
    }
    
    func get(key: Data) async throws -> (data: Data, references: [Data])? {
        keyMock = key
        return (data: dataMock, references: referencesMock)
    }
}

@MainActor
struct CASServiceTests {
    let sut: CASService
    let blobRepository: MockCASBlobRepository
    let objectRepository: MockCASObjectRepository
    
    init() {
        blobRepository = MockCASBlobRepository()
        objectRepository = MockCASObjectRepository()
        sut = CASService(
            blobRepository: blobRepository,
            objectRepository: objectRepository
        )
    }
    
    @Test func save_success() async throws {
        let data = Data("data".utf8)
        let request: CompilationCacheService_Cas_V1_CASDBService.Method.Save.Input = .with {
            $0.data = .with {
                $0.blob = .with {
                    $0.data = data
                }
            }
        }
        blobRepository.keyMock = Data("key".utf8)
                
        let result = try await sut.save(request: request, context: .stub)
        
        #expect(result.casID.id == blobRepository.keyMock)
        #expect(blobRepository.valueMock == data)
    }
    
    @Test func load_success() async throws {
        let key = Data("key".utf8)
        let request: CompilationCacheService_Cas_V1_CASDBService.Method.Load.Input = .with {
            $0.casID = .with {
                $0.id = key
            }
        }
        blobRepository.valueMock = Data("data".utf8)
                
        let result = try await sut.load(request: request, context: .stub)
        
        #expect(result.data.blob.data == blobRepository.valueMock)
        #expect(blobRepository.keyMock == key)
    }
}
