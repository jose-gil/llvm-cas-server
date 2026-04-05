import Foundation
import GRPCCore
import Logging

struct KeyValueService: CompilationCacheService_Keyvalue_V1_KeyValueDB.SimpleServiceProtocol {
    private let repository: KeyValueRepository
    
    init(repository: KeyValueRepository) {
        self.repository = repository
    }
    
    func putValue(
        request: CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.PutValue.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.PutValue.Output {
        do {
            Logger.keyValue.debug("putValue -- \(request.key.toCasID())")
            let value = try request.value.serializedData()
            try await repository.setValue(key: request.key, value: value)
            return .init()
        } catch {
            return .with {
                $0.error = .with {
                    $0.description_p = "Cache error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func getValue(
        request: CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.GetValue.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.GetValue.Output {        
        do {
            if let data = try await repository.getValue(key: request.key) {
                let value = try CompilationCacheService_Keyvalue_V1_Value(serializedBytes: data)
                Logger.keyValue.debug("getValue - successs - \(request.key.toCasID())")
                return .with {
                    $0.outcome = .success
                    $0.value = value
                }
            } else {
                Logger.keyValue.debug("getValue - not found - \(request.key.toCasID())")
                return .with {
                    $0.outcome = .keyNotFound
                }
            }
        } catch {
            Logger.keyValue.debug("getValue - error - \(request.key.toCasID())")
            return .with {
                $0.outcome = .error
                $0.error = .with {
                    $0.description_p = "getValue - error: \(error.localizedDescription)"
                }
            }
        }
    }
}
