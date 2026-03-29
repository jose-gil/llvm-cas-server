import GRPCCore
import GRPCNIOTransportHTTP2

@main
struct Server {
    static func main() async throws {
        guard let local = try? GRDBKeyValueDataSource(path: "") else {
            return
        }
       
        let port: Int = 9932
        let cache = NSDataKeyValueSource(limit: 100)
        let repository = DefaultKeyValueRepository(cache: cache, local: local)

        let server = GRPCServer(
            transport: .http2NIOPosix(
                address: .ipv4(host: "127.0.0.1", port: port),
                transportSecurity: .plaintext
            ),
            services: [CASService(), KeyValueService(repository: repository)]
        )
        
        try await withThrowingDiscardingTaskGroup { group in
            group.addTask { try await server.serve() }
            if let address = try await server.listeningAddress {
                print("Server listening on \(address)")
            }
        }
    }
}
