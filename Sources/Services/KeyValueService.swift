import Foundation
import GRPCCore

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
            let key = request.key
            let valueData = try request.value.serializedData()
            
            try await repository.setValue(key: key, value: valueData)            
            return .with { _ in }
        } catch {
            return .with {
                $0.error = .with {
                    $0.description_p = "Chache error: \(error.localizedDescription)"
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
                let cachedValue = try CompilationCacheService_Keyvalue_V1_Value(serializedBytes: data)
                
                return .with {
                    $0.outcome = .success
                    $0.value = cachedValue
                }
            } else {
                return .with {
                    $0.outcome = .keyNotFound
                }
            }
        } catch {
            return .with {
                $0.outcome = .error
                $0.error = .with {
                    $0.description_p = "Internal error: \(error.localizedDescription)"
                }
            }
        }
    }
}
