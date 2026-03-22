import GRPCCore

struct CASService: CompilationCacheService_Cas_V1_CASDBService.SimpleServiceProtocol {
    func save(request: CompilationCacheService_Cas_V1_CASSaveRequest, context: GRPCCore.ServerContext) async throws -> CompilationCacheService_Cas_V1_CASSaveResponse {
        return CompilationCacheService_Cas_V1_CASSaveResponse()
    }
    
    func load(request: CompilationCacheService_Cas_V1_CASLoadRequest, context: GRPCCore.ServerContext) async throws -> CompilationCacheService_Cas_V1_CASLoadResponse {
        return CompilationCacheService_Cas_V1_CASLoadResponse()
    }
    
    func put(request: CompilationCacheService_Cas_V1_CASPutRequest, context: GRPCCore.ServerContext) async throws -> CompilationCacheService_Cas_V1_CASPutResponse {
        return CompilationCacheService_Cas_V1_CASPutResponse()
    }
    
    func get(request: CompilationCacheService_Cas_V1_CASGetRequest, context: GRPCCore.ServerContext) async throws -> CompilationCacheService_Cas_V1_CASGetResponse {
        return CompilationCacheService_Cas_V1_CASGetResponse()
    }
}
