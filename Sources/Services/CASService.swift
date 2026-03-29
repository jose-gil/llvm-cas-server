import Foundation
import GRPCCore

struct CASService: CompilationCacheService_Cas_V1_CASDBService.SimpleServiceProtocol {
    private let repository: CASRepository

    init(repository: CASRepository) {
        self.repository = repository
    }
    
    func save(
        request: CompilationCacheService_Cas_V1_CASDBService.Method.Save.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Cas_V1_CASDBService.Method.Save.Output {
        let dataToSave = request.data.blob.data
        
        guard !dataToSave.isEmpty else {
            return .with {
                $0.error = .with { $0.description_p = "Empty data" }
            }
        }
        
        do {
            let hashID = try await repository.set(value: dataToSave)
            return .with {
                $0.casID = .with { $0.id = hashID }
            }
        } catch {
            return .with {
                $0.error = .with { $0.description_p = "Internal Save Error: \(error.localizedDescription)" }
            }
        }
    }
    
    func load(
        request: CompilationCacheService_Cas_V1_CASDBService.Method.Load.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Cas_V1_CASDBService.Method.Load.Output {
        let key = request.casID.id        
        do {
            if let data = try await repository.get(key: key) {
                return .with {
                    $0.outcome = .success
                    $0.data = .with { blob in
                        blob.blob = .with { $0.data = data }
                    }
                }
            } else {
                return .with {
                    $0.outcome = .objectNotFound
                }
            }
        } catch {
            return .with {
                $0.outcome = .error
                $0.error = .with { $0.description_p = "Internal Load Error: \(error.localizedDescription)" }
            }
        }
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
