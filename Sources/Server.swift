import GRPCCore
import GRPCNIOTransportHTTP2

@main
struct Server {
    static func main() async throws {
        let port: Int = 9093
        let rootPath: String = "/tmp/llvm-cas"
        let cache = NSDataKeyValueSource(limit: 100)
        let local = try GRDBKeyValueDataSource(path: rootPath)
        let kevValueRepository = DefaultKeyValueRepository(cache: cache, local: local)
        let casBlobRepository = try DiskCASBlobRepository(rootPath: rootPath)
        let casObjectRepository = try DiskCASObjectRepository(rootPath: rootPath)

        let server = GRPCServer(
            transport: .http2NIOPosix(
                address: .ipv4(host: "0.0.0.0", port: port),
                transportSecurity: .plaintext
            ),
            services: [
                CASService(blobRepository: casBlobRepository, objectRepository: casObjectRepository),
                KeyValueService(repository: kevValueRepository)
            ]
        )
        
        try await withThrowingDiscardingTaskGroup { group in
            group.addTask { try await server.serve() }
            if let address = try await server.listeningAddress {
                print("Server listening on \(address)")
            }
        }
    }
}
