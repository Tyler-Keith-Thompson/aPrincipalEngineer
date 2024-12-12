//
//  OpenFGAService.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Vapor
import Afluent
import DependencyInjection
import Mockable

@Mockable
protocol OpenFGAService {
    func checkAuthorization(client: Vapor.Client, tuples: [any _OpenFGATuple], contextualTuples: [any _OpenFGATuple]) async throws -> OpenFGABatchCheckResponse
    func createRelation(client: Vapor.Client, tuples: [any _OpenFGATuple]) async throws
    func deleteRelation(client: Vapor.Client, tuples: [any _OpenFGATuple]) async throws
}

extension _OpenFGATuple {
    typealias RidiculousWayToReferenceABoolean = Bool
    fileprivate func unsafeStupidExcuseToUseTheType(_ arr: inout [(any _OpenFGATuple, Bool)]) -> (RidiculousWayToReferenceABoolean) {
        arr.popLast()!.1
    }
}

extension OpenFGAService {
    func checkAuthorization<each Tuple: _OpenFGATuple>(client: Vapor.Client, _ tuple: repeat (each Tuple), contextualTuples: OpenFGATuple...) async throws -> (repeat (each Tuple).RidiculousWayToReferenceABoolean) {
        var tuples = [any _OpenFGATuple]()
        for (tuple) in repeat (each tuple) {
            tuples.append(tuple)
        }
        let order = tuples.enumerated().reduce(into: [UUID: Int]()) {
            $0[$1.element.correlationID] = $1.offset
        }
        
        let response = try await checkAuthorization(client: client, tuples: tuples, contextualTuples: contextualTuples).result.responses
        guard response.count >= tuples.count else { throw _OpenFGAService.Error.invalidBatchResponseFromServer }
        let orderedResponse = try response.reduce(into: Array<OpenFGACheckResponse?>(repeating: nil, count: response.count)) {
            guard let id = $1.id, let position = order[id] else { throw _OpenFGAService.Error.invalidBatchResponseFromServer }
            $0[position] = $1
        }.compactMap { $0 }
        guard orderedResponse.count == tuples.count else { throw _OpenFGAService.Error.invalidBatchResponseFromServer }
        var transformed = Array(tuples.enumerated().map {
            ($0.element, orderedResponse[$0.offset].allowed)
        }.reversed())
        return (repeat (each tuple).unsafeStupidExcuseToUseTheType(&transformed))
    }
    
    func createRelation(client: Vapor.Client, _ tuple: any _OpenFGATuple, _ tuples: any _OpenFGATuple...) async throws {
        try await createRelation(client: client, tuples: [tuple] + tuples)
    }
    
    func deleteRelation(client: Vapor.Client, _ tuple: any _OpenFGATuple, _ tuples: any _OpenFGATuple...) async throws {
        try await deleteRelation(client: client, tuples: [tuple] + tuples)
    }
}

final class _OpenFGAService: OpenFGAService {
    enum Error: Swift.Error {
        case noOpenFGAURL
        case failedToWrite
        case invalidBatchResponseFromServer
    }
    
    let cache = AUOWCache()
    
    func createRelation(client: Vapor.Client, tuples: [any _OpenFGATuple]) async throws {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let createRequest = OpenFGAWriteTupleRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                     writes: .init(tuple_keys: tuples.map(OpenFGATuple.init)),
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
    
    func deleteRelation(client: Vapor.Client, tuples: [any _OpenFGATuple]) async throws {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let createRequest = OpenFGAWriteTupleRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                     writes: nil,
                                                     deletes: .init(tuple_keys: tuples.map(OpenFGATuple.init)))
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
    
    func checkAuthorization(client: Vapor.Client, tuples: [any _OpenFGATuple], contextualTuples: [any _OpenFGATuple]) async throws -> OpenFGABatchCheckResponse {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let batchRequest = OpenFGABatchCheckRequest(checks: tuples.map {
            OpenFGACheckRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                tuple_key: OpenFGATuple(existential: $0),
                                contextual_tuples: .init(tuple_keys: contextualTuples.map(OpenFGATuple.init)))
        })
        var hasher = Hasher()
        batchRequest.hash(into: &hasher)
        let hashValue = hasher.finalize()
        if let cachedResult = try? await Container.inMemoryCache()?.get("\(hashValue)_checkAuthorization", as: OpenFGABatchCheckResponse.self) {
            return cachedResult
        }

        return try await DeferredTask {
            try await client.post("\(openFGAURL)/stores/01JEG4F6KBEGFH9DMQ59J7A3XD/batch-check",
                                  content: batchRequest)
        }
        .shareFromCache(cache, strategy: .cacheUntilCompletionOrCancellation, keys: batchRequest)
        .tryMap {
            try $0.content.decode(OpenFGABatchCheckResponse.self)
        }
        .handleEvents(receiveOutput: {
            try? await Container.inMemoryCache()?.set("\(hashValue)_checkAuthorization", to: $0, expiresIn: .minutes(30))
        })
        .execute()
    }
}

#if DEBUG
final class DebugOpenFGAService: OpenFGAService {
    func checkAuthorization(client: Vapor.Client, tuples: [any _OpenFGATuple], contextualTuples: [any _OpenFGATuple]) async throws -> OpenFGABatchCheckResponse {
        .init(result: .init(responses: tuples.map { tuple in
            OpenFGACheckResponse(allowed: true, id: tuple.correlationID)
        }))
    }
    
    func createRelation(client: Vapor.Client, tuples: [any _OpenFGATuple]) async throws { }
    
    func deleteRelation(client: Vapor.Client, tuples: [any _OpenFGATuple]) async throws { }
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
    func ensureUser<Object: OpenFGAModel>(_ tuple: (Object.Relation, Object), _ tuples: (Object.Relation, Object)...) async throws {
        let userTypeTuple = try auth.userTypeTuple
        let allTuples = try ([tuple] + tuples).map { try OpenFGATuple(user: userTypeTuple, relation: $0, object: $1) }
        guard try await Container.openFGAService().checkAuthorization(client: client, tuples: allTuples, contextualTuples: []).result.responses.allSatisfy({ $0.allowed }) else {
            throw Abort(.forbidden)
        }
    }

    func ensureUser<Object: OpenFGAModel>(_ relation: Object.Relation, object: Object) async throws {
        guard try await Container.openFGAService().checkAuthorization(client: client, OpenFGATuple(user: auth.userTypeTuple, relation: relation, object: object)) else {
            throw Abort(.forbidden)
        }
    }
}
