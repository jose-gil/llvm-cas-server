import Foundation
import GRPCCore

struct KeyValueService: CompilationCacheService_Keyvalue_V1_KeyValueDB.SimpleServiceProtocol {
    private var cacheServer: ActionCacheDatabaseStorage? {
        try? ActionCacheDatabaseStorage(path: "")
    }
    
    func putValue(
        request: CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.PutValue.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.PutValue.Output {
        let key: Data = request.key
        let value: Data = try request.value.serializedData()
        
        var response = CompilationCacheService_Keyvalue_V1_PutValueResponse()
        do {
            try cacheServer?.putValue(key: key, value: value)
            return response
        } catch {
            var responseError = CompilationCacheService_Keyvalue_V1_ResponseError()
            responseError.description_p = "Error al guardar en caché: \(error.localizedDescription)"
            response.error = responseError
            return response
        }
    }
    
    func getValue(
        request: CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.GetValue.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Keyvalue_V1_KeyValueDB.Method.GetValue.Output {
        let key: Data = request.key

        var response = CompilationCacheService_Keyvalue_V1_GetValueResponse()
        do {
            if let data = try cacheServer?.getValue(key: key) {
                response.outcome = .success
                response.value = try CompilationCacheService_Keyvalue_V1_Value(serializedBytes: data)
            } else {
                response.outcome = .keyNotFound
            }
        } catch {
            response.outcome = .error
            var errorDetail = CompilationCacheService_Keyvalue_V1_ResponseError()
            errorDetail.description_p = "Error interno: \(error.localizedDescription)"
            response.error = errorDetail
        }
            
        return response
    }
}
