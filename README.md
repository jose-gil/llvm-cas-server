# Swift LLVM CAS Server (llvm-cas-server)

A high-performance Content Addressable Storage (CAS) server implementation written in Swift, inspired by the [LLVM CAS infrastructure](https://llvm.org/docs/ContentAddressableStorage.html) and usign [protos](
https://github.com/swiftlang/llvm-project/blob/next/llvm/lib/RemoteCachingService/RemoteCacheProto/compilation_caching_cas.proto#L24).

## KeyValue Service (ActionCache)

The KeyValue or ActionCache: This is a map that associates a "Question" with an "Answer". It is mutable (you can update the result of a compilation if, for example, you change the compiler version).

It has two services:

- PutValueRequest -> key: Data, Value: Dictonary<String, Data> -> # -> PutValueResponse. You put all your inputs referecenes related with CASID (the source code of main.c, the compiler flags -O3, the headers).

- GetValueRequest -> key: Data -> # -> GetValueResponse -> Value: Dictonary<String, Data>. You ask the service: "Has anyone already executed the action with this CASID?".

## CAS Service

This is a service where the "key" is the hash of the content. If you give it the same file twice, it gives you the same key. It is immutable.

The basic unit of the CAS library is a `CASObject`, where it contains:
* data - `CASBytes`: arbitrary data
* references - array<CASDataID> : references to other CASObject

CASDataID:: id: Data
CASObject:: blob: CASBytes , references: CASDataID
CASBlob:: blob: CASBytes
CASBytes:: data: Data | filepath: String
ResponseError:: description: String

- CASSaveRequest -> data: CASBlob -> blob: CASBytes  -> data: Data, file_path: String # -> CASSaveResponse -> contents: CASDataID -> id: Data
- CASLoadRequest -> cas_id: CASDataID, write_to_file: Bool -> id: Data -> # -> CASLoadResponse -> contents: CASBlob -> blob: CASBytes -> data: Data

- CASGetRequest -> CASDataID -> id -> # -> CASGetResponse -> CASObject -> CASBytes, Array<CASDataID>
- CASPutRequest -> CASObject -> CASBytes, Array<CASDataID> -> # -> CASPUTResponse -> CASDataID -> id

## Contribute

```bash
PROTOC_PATH=$(which protoc) open Package.swift
```
