//
//  OpenFGAService.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Vapor
import Afluent
import DependencyInjection

// http://openfga-wild-darkness-6310.flycast
// https://openfga.dev/docs/interacting/transactional-writes
//curl -X POST $FGA_API_URL/stores/$FGA_STORE_ID/check \
//  -H "Authorization: Bearer $FGA_API_TOKEN" \ # Not needed if service does not require authorization
//  -H "content-type: application/json" \
//  -d '{"authorization_model_id": "01HVMMBCMGZNT3SED4Z17ECXCA", "tuple_key":{"user":"user:6b0b14af-59dc-4ff3-a46f-ad351f428726","relation":"viewer","object":"document:product-launch"},"contextual_tuples":{"tuple_keys":[{"user":"user:6b0b14af-59dc-4ff3-a46f-ad351f428726","relation":"member","object":"group:marketing"},{"user":"user:6b0b14af-59dc-4ff3-a46f-ad351f428726","relation":"member","object":"group:everyone"}]}}'

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
                return try .init(type: "guest", id: request.id)
            }
        }()
        let checkRequest = try OpenFGACheckRequest(authorization_model_id: Environment.get("OpenFGA_AUTHORIZATION_MODEL_ID"),
                                                   tuple_key: .init(user: userTypeTuple, relation: relation.rawValue, object: .init(type: object.openFGATypeName, id: object.openFGAID)),
                                                   contextual_tuples: .init(tuple_keys: []))
        return try await DeferredTask {
            try await request.client.post("\(openFGAURL)/stores/01JEG4F6KBEGFH9DMQ59J7A3XD/check",
                                          content: checkRequest)
        }
        .shareFromCache(cache, strategy: .cacheUntilCompletionOrCancellation, keys: checkRequest)
        .tryMap {
            try $0.content.decode(OpenFGACheckResponse.self).allowed
        }
        .execute()
    }
}

extension Container {
    static let openFGAService = Factory(scope: .shared) { _OpenFGAService() as OpenFGAService }
}

extension Request {
    func ensureUser<Object: OpenFGAModel>(_ relation: Object.Relation, object: Object) async throws {
        guard try await Container.openFGAService().checkAuthorization(request: self, relation: relation, object: object) else {
            throw Abort(.unauthorized)
        }
    }
}
