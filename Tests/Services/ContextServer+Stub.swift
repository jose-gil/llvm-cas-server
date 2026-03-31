import GRPCCore

extension ServerContext {
    static let stub = ServerContext(
        descriptor: .init(
            service: .init(
                package: "",
                service: ""
            ),
            method: ""
        ),
        remotePeer: "",
        localPeer: "",
        cancellation: ServerContext.RPCCancellationHandle.init()
    )
}
