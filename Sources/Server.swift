import GRPCCore
import GRPCNIOTransportHTTP2

@main
struct Server {
    static func main() async throws {
        let port: Int = 9932
        let cache = NSDataKeyValueSource(limit: 100)
        let local = try GRDBKeyValueDataSource(path: "")
        let kevValueRepository = DefaultKeyValueRepository(cache: cache, local: local)
        let casBlobRepository = try DiskCASBlobRepository(rootPath: "")
        let casObjectRepository = try DiskCASObjectRepository(rootPath: "")

        let server = GRPCServer(
            transport: .http2NIOPosix(
                address: .ipv4(host: "127.0.0.1", port: port),
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
