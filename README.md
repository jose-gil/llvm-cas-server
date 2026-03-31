# Swift LLVM CAS Server (llvm-cas-server)

A high-performance Content Addressable Storage (CAS) server implementation written in Swift, inspired by the [LLVM CAS infrastructure](https://llvm.org/docs/ContentAddressableStorage.html) and usign [protos](
https://github.com/swiftlang/llvm-project/blob/next/llvm/lib/RemoteCachingService/RemoteCacheProto/compilation_caching_cas.proto#L24).

## KeyValue Service (ActionCache)

The KeyValue or ActionCache: This is a map that associates a "Question" with an "Answer". It is mutable (you can update the result of a compilation if, for example, you change the compiler version).

It has two services:

- PutValueRequest:  You put all your inputs referecenes related with CASID (the source code of main.c, the compiler flags -O3, the headers).
-> key: `Data`, Value: `Dictonary<String, Data>` -> # -> PutValueResponse.

- GetValueRequest: You ask the service: "Has anyone already executed the action with this CASID?".
-> key: `Data` -> # -> GetValueResponse -> Value: `Dictonary<String, Data>`. 

## CAS Service

This is a service where the "key" is the hash of the content. If you give it the same file twice, it gives you the same key. It is immutable.

The basic unit of the CAS library is a `CASObject`, where it contains:
* blob - `CASBytes`: arbitrary data
* references - `Array<CASDataID>`: references to other CASObject

- CASSaveRequest: Save the blob (data) and return a CASID for this blob.
-> data: CASBlob -> blob: CASBytes -> data: `Data`, file_path: `String` # -> CASSaveResponse -> contents: CASDataID -> id: `Data`

- CASLoadRequest: Return the blob (data) using a CASID.
-> cas_id: CASDataID, write_to_file: `Bool` -> id: `Data` -> # -> CASLoadResponse -> contents: CASBlob -> blob: CASBytes -> data: `Data`

- CASPutRequest: Save the object (data) and a array of references (CASID) and return a CASID for this object.
 -> CASObject -> blob: CASBytes, reference: `Array<CASDataID>` -> # -> CASPUTResponse -> CASDataID -> id: `Data`

- CASGetRequest: Return the object (data an de refe¡rences)
 -> CASDataID -> id: `Data` -> # -> CASGetResponse -> CASObject -> blob: CASBytes, references: `Array<CASDataID>`

## Contribute

```bash
PROTOC_PATH=$(which protoc) open Package.swift
```
