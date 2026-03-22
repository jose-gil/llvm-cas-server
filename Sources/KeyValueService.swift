import GRPCCore

struct KeyValueService: CompilationCacheService_Keyvalue_V1_KeyValueDB.SimpleServiceProtocol {
    func putValue(request: CompilationCacheService_Keyvalue_V1_PutValueRequest, context: GRPCCore.ServerContext) async throws -> CompilationCacheService_Keyvalue_V1_PutValueResponse {
        return CompilationCacheService_Keyvalue_V1_PutValueResponse()
    }
    
    func getValue(request: CompilationCacheService_Keyvalue_V1_GetValueRequest, context: GRPCCore.ServerContext) async throws -> CompilationCacheService_Keyvalue_V1_GetValueResponse {
        return CompilationCacheService_Keyvalue_V1_GetValueResponse()
    }
}
