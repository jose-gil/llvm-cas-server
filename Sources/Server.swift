import GRPCCore
import GRPCNIOTransportHTTP2

@main
struct Server {
    static func main() async throws {
        guard let local = try? GRDBKeyvalueDataSource(path: "") else {
            return
        }
       
        let port: Int = 9932
        let cache = NSDataKeyvalueSource(limit: 100)
        let repository = DefaultKeyvalueRepository(cache: cache, local: local)

        let server = GRPCServer(
            transport: .http2NIOPosix(
                address: .ipv4(host: "127.0.0.1", port: port),
                transportSecurity: .plaintext
            ),
            services: [CASService(), KeyvalueService(repository: repository)]
        )
        
        try await withThrowingDiscardingTaskGroup { group in
            group.addTask { try await server.serve() }
            if let address = try await server.listeningAddress {
                print("Server listening on \(address)")
            }
        }
    }
}
