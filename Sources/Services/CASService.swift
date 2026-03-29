import Foundation
import GRPCCore

struct CASService: CompilationCacheService_Cas_V1_CASDBService.SimpleServiceProtocol {
    private let blobRepository: CASBlobRepository
    private let objectRepository: CASObjectRepository
    
    init(blobRepository: CASBlobRepository, objectRepository: CASObjectRepository) {
        self.blobRepository = blobRepository
        self.objectRepository = objectRepository
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
            let hashID = try await blobRepository.set(value: dataToSave)
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
            if let data = try await blobRepository.get(key: key) {
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
        do {
            let data = request.data.blob.data
            let references = request.data.references.map { $0.id }
            
            let casID = try await objectRepository.set(data: data, references: references)
            
            return .with {
                $0.casID = .with { $0.id = casID }
            }
        } catch {
            return .with {
                $0.error = .with { $0.description_p = error.localizedDescription }
            }
        }
    }
    
    func get(
        request: CompilationCacheService_Cas_V1_CASDBService.Method.Get.Input,
        context: ServerContext
    ) async throws -> CompilationCacheService_Cas_V1_CASDBService.Method.Get.Output {
        do {
            if let result = try await objectRepository.get(key: request.casID.id) {
                return .with {
                    $0.outcome = .success
                    $0.data = .with { obj in
                        obj.blob = .with { $0.data = result.data }
                        obj.references = result.references.map { refID in
                                .with { $0.id = refID }
                        }
                    }
                }
            } else {
                return .with { $0.outcome = .objectNotFound }
            }
        } catch {
            return .with {
                $0.outcome = .error
                $0.error = .with { $0.description_p = error.localizedDescription }
            }
        }
    }
}
