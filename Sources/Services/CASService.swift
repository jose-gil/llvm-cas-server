import Foundation
import GRPCCore

struct CASService: CompilationCacheService_Cas_V1_CASDBService.SimpleServiceProtocol {
    func save(
        request: CompilationCacheService_Cas_V1_CASDBService.Method.Save.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Cas_V1_CASDBService.Method.Save.Output {
        let data = request.data.blob.data
        
        var response = CompilationCacheService_Cas_V1_CASSaveResponse()
        
        var casID = CompilationCacheService_Cas_V1_CASDataID()
//        casID.id = convertKeyToCasID(data)
        
        return .init()
    }
    
    func load(
        request: CompilationCacheService_Cas_V1_CASDBService.Method.Load.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Cas_V1_CASDBService.Method.Load.Output {
        return .init()
    }
    
    func put(
        request: CompilationCacheService_Cas_V1_CASDBService.Method.Put.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Cas_V1_CASDBService.Method.Put.Output {
        return .init()
    }
    
    func get(
        request: CompilationCacheService_Cas_V1_CASDBService.Method.Get.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Cas_V1_CASDBService.Method.Get.Output {
        return .init()
    }
    
    private func convertKeyToCasID(_ key: Data) -> String {
        "0~" + key.dropFirst().base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
    }
}
