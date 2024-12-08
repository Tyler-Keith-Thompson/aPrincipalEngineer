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
    func checkAuthorization<Object: OpenFGAModel>(request: Vapor.Request, relation: Object.Relation, object: Object) async throws -> Bool
    func createRelation(client: Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws
    func deleteRelation(client: Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws
}

final class _OpenFGAService: OpenFGAService {
    enum Error: Swift.Error {
        case noOpenFGAURL
        case failedToWrite
    }
    
    let cache = AUOWCache()
    
    func createRelation(client: Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let createRequest = OpenFGAWriteTupleRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                     writes: .init(tuple_keys: [tuple] + tuples),
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
    
    func deleteRelation(client: Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let createRequest = OpenFGAWriteTupleRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                     writes: nil,
                                                     deletes: .init(tuple_keys: [tuple] + tuples))
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
    
    func checkAuthorization<Object: OpenFGAModel>(request: Vapor.Request, relation: Object.Relation, object: Object) async throws -> Bool {
        guard let openFGAURL = Environment.get("OpenFGA_URL") else { throw Error.noOpenFGAURL }
        let userTypeTuple: OpenFGATuple.OpenFGATypeTuple = try {
            if let user = request.auth.get(User.self) {
                return try .init(type: "user", id: user.requireID().uuidString)
            } else {
                return try .init(type: "guest", id: "anonymous")
            }
        }()
        let checkRequest = try OpenFGACheckRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                   tuple_key: .init(user: userTypeTuple, relation: relation.rawValue, object: .init(type: object.openFGATypeName, id: object.openFGAID)),
                                                   contextual_tuples: .init(tuple_keys: []))
        var hasher = Hasher()
        checkRequest.hash(into: &hasher)
        let hashValue = hasher.finalize()
        if let cachedResult = try? await Container.inMemoryCache()?.get("\(hashValue)_checkAuthorization", as: Bool.self) {
            return cachedResult
        }

        return try await DeferredTask {
            try await request.client.post("\(openFGAURL)/stores/01JEG4F6KBEGFH9DMQ59J7A3XD/check",
                                          content: checkRequest)
        }
        .shareFromCache(cache, strategy: .cacheUntilCompletionOrCancellation, keys: checkRequest)
        .tryMap {
            try $0.content.decode(OpenFGACheckResponse.self).allowed
        }
        .handleEvents(receiveOutput: {
            try? await Container.inMemoryCache()?.set("\(hashValue)_checkAuthorization", to: $0, expiresIn: .minutes(30))
        })
        .execute()
    }
}

#if DEBUG
final class DebugOpenFGAService: OpenFGAService {
    func checkAuthorization<Object: OpenFGAModel>(request: Vapor.Request, relation: Object.Relation, object: Object) async throws -> Bool { true }
    
    func createRelation(client: any Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws { }
    
    func deleteRelation(client: any Vapor.Client, _ tuple: OpenFGATuple, _ tuples: OpenFGATuple...) async throws { }
}
#endif

extension Container {
    static let openFGAService = Factory(scope: .shared) {
#if DEBUG
        DebugOpenFGAService() as OpenFGAService
#else
        _OpenFGAService() as OpenFGAService
#endif
    }
}

extension Request {
    func ensureUser<Object: OpenFGAModel>(_ relation: Object.Relation, object: Object) async throws {
        guard try await Container.openFGAService().checkAuthorization(request: self, relation: relation, object: object) else {
            throw Abort(.unauthorized)
        }
    }
}
