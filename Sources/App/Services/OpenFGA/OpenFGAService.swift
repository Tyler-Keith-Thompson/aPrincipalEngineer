//
//  OpenFGAService.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Vapor
import Afluent
import DependencyInjection

protocol OpenFGAService {
    func checkAuthorization(client: Vapor.Client, tuples: [OpenFGATuple], contextualTuples: [OpenFGATuple]) async throws -> Bool
    func createRelation(client: Vapor.Client, tuples: [OpenFGATuple]) async throws
    func deleteRelation(client: Vapor.Client, tuples: [OpenFGATuple]) async throws
}

extension OpenFGAService {
    func checkAuthorization(client: Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple..., contextualTuples: OpenFGATuple...) async throws -> Bool {
        try await checkAuthorization(client: client, tuples: [tuple] + tuples, contextualTuples: contextualTuples)
    }
    
    func createRelation(client: Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws {
        try await createRelation(client: client, tuples: [tuple] + tuples)
    }
    
    func deleteRelation(client: Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws {
        try await deleteRelation(client: client, tuples: [tuple] + tuples)
    }
}

final class _OpenFGAService: OpenFGAService {
    enum Error: Swift.Error {
        case noOpenFGAURL
        case failedToWrite
    }
    
    let cache = AUOWCache()
    
    func createRelation(client: Vapor.Client, tuples: [OpenFGATuple]) async throws {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let createRequest = OpenFGAWriteTupleRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                     writes: .init(tuple_keys: tuples),
                                                     deletes: nil)
        try await DeferredTask {
            try await client.post("\(openFGAURL)/stores/01JEG4F6KBEGFH9DMQ59J7A3XD/write",
                                                 content: createRequest)
        }
        .shareFromCache(cache, strategy: .cacheUntilCompletionOrCancellation, keys: createRequest)
        .tryMap {
            guard $0.status == .ok else { throw Error.failedToWrite }
        }
        .execute()
    }
    
    func deleteRelation(client: Vapor.Client, tuples: [OpenFGATuple]) async throws {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let createRequest = OpenFGAWriteTupleRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                     writes: nil,
                                                     deletes: .init(tuple_keys: tuples))
        try await DeferredTask {
            try await client.post("\(openFGAURL)/stores/01JEG4F6KBEGFH9DMQ59J7A3XD/write",
                                  content: createRequest)
        }
        .shareFromCache(cache, strategy: .cacheUntilCompletionOrCancellation, keys: createRequest)
        .tryMap {
            guard $0.status == .ok else { throw Error.failedToWrite }
        }
        .execute()
    }
    
    func checkAuthorization(client: Vapor.Client, tuples: [OpenFGATuple], contextualTuples: [OpenFGATuple]) async throws -> Bool {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let batchRequest = OpenFGABatchCheckRequest(checks: tuples.map {
            OpenFGACheckRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                tuple_key: $0,
                                contextual_tuples: .init(tuple_keys: contextualTuples))
        })
        var hasher = Hasher()
        batchRequest.hash(into: &hasher)
        let hashValue = hasher.finalize()
        if let cachedResult = try? await Container.inMemoryCache()?.get("\(hashValue)_checkAuthorization", as: Bool.self) {
            return cachedResult
        }

        return try await DeferredTask {
            try await client.post("\(openFGAURL)/stores/01JEG4F6KBEGFH9DMQ59J7A3XD/batch-check",
                                  content: batchRequest)
        }
        .shareFromCache(cache, strategy: .cacheUntilCompletionOrCancellation, keys: batchRequest)
        .tryMap {
            try $0.content.decode(OpenFGABatchCheckResponse.self).result.responses.allSatisfy(\.allowed)
        }
        .handleEvents(receiveOutput: {
            try? await Container.inMemoryCache()?.set("\(hashValue)_checkAuthorization", to: $0, expiresIn: .minutes(30))
        })
        .execute()
    }
}

#if DEBUG
final class DebugOpenFGAService: OpenFGAService {
    func checkAuthorization(client: Vapor.Client, tuples: [OpenFGATuple], contextualTuples: [OpenFGATuple]) async throws -> Bool { true }
    
    func createRelation(client: Vapor.Client, tuples: [OpenFGATuple]) async throws { }
    
    func deleteRelation(client: Vapor.Client, tuples: [OpenFGATuple]) async throws { }
}
#endif

extension Container {
    static let openFGAService = Factory {
#if DEBUG
        DebugOpenFGAService() as OpenFGAService
#else
        _OpenFGAService() as OpenFGAService
#endif
    }
}

extension Request {
    func ensureUser<Object: OpenFGAModel>(_ relation: Object.Relation, object: Object) async throws {
        guard try await Container.openFGAService().checkAuthorization(client: client, .init(user: auth.userTypeTuple, relation: relation, object: object)) else {
            throw Abort(.unauthorized)
        }
    }
}
