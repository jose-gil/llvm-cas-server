# Swift LLVM CAS Server (llvm-cas-server)

A high-performance Content Addressable Storage (CAS) server implementation written in Swift, inspired by the [LLVM CAS infrastructure](https://llvm.org/docs/ContentAddressableStorage.html).

https://github.com/swiftlang/llvm-project/blob/next/llvm/lib/RemoteCachingService/RemoteCacheProto/compilation_caching_cas.proto#L24

## CAS Service

The basic unit of the CAS library is a `CASObject`, where it contains:
* Data: arbitrary data
* References: references to other CASObject

CASDataID:: id: Data
CASObject:: blob: CASBytes , references: CASDataID
CASBlob:: blob: CASBytes
CASBytes:: data: Data | filepath: String
ResponseError:: description: String

-> CASSaveRequest -> CASBlob -> CASBytes -> data -> # -> CASSaveResponse -> CASDataID -> id
-> CASLoadRequest -> CASDataID -> id -> # -> CASLoadResponse -> CASBlob -> CASBytes -> data

-> CASGetRequest -> CASDataID -> id -> # -> CASGetResponse -> CASObject -> CASBytes, Array<CASDataID>
-> CASPutRequest -> CASObject -> CASBytes, Array<CASDataID> -> # -> CASPUTResponse -> CASDataID -> id

## Key Value Service

Key value storage can be used to associate two CASIDs. It is usually used with an ObjectStore to map an input CASObject to an output CASObject with their CASIDs.

Value:: entries: Dictionary<String,Data>

-> PutValueRequest -> key: Data | Value -> entries -> # -> PutValueResponse
-> GetValueRequest -> key: Data -> # -> GetValueResponse  -> Value -> entries

## Contribute

```bash
PROTOC_PATH=$(which protoc) open Package.swift
```
