//
//  PermissionsMigration.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Fluent
import Vapor
import DependencyInjection

struct InitialPermissionsMigration: AsyncMigration {
    @Injected(Container.openFGAService) private var openFGAService
    let client: Vapor.Client
    let container = Container.current
    
    func prepare(on database: Database) async throws {
        try await withContainer(container) {
            let prodTyler = try await User.find(UUID(uuidString: "c6b2b5d9-cfcf-4d5d-b818-12d9e4fcd6c3"), on: database)
            let debugTyler = try await User.find(UUID(uuidString: "6D50873A-D6EE-4B1E-9ADF-99067B2B4467"), on: database)
            guard let tyler = prodTyler ?? debugTyler else { return }
            guard let restNetworkingLayer = try await BlogPost.find(UUID(uuidString: "b35c209e-d2c1-475b-86af-333294c9407e"), on: database),
                  let automatedTestingUndesirableChange = try await BlogPost.find(UUID(uuidString: "1665046f-18ba-4005-9122-b708a28640dc"), on: database),
                  let automatedTestingDesirableChange = try await BlogPost.find(UUID(uuidString: "de43ae83-2feb-4b2f-9a7d-25f6078fb547"), on: database),
                  let automatedTestingCost = try await BlogPost.find(UUID(uuidString: "fa44f008-9f2e-4152-af22-c9359d1d206c"), on: database),
                  let automatedTestingFalseNegative = try await BlogPost.find(UUID(uuidString: "4d4b70cc-1bbd-4505-a40e-33376d494302"), on: database),
                  let automatedTestingFalsePositive = try await BlogPost.find(UUID(uuidString: "fde72d71-6b59-49a6-bca5-419c12835348"), on: database),
                  let automatedTestingProximity = try await BlogPost.find(UUID(uuidString: "733037c5-960e-4ed8-8190-d1fd72fb24d6"), on: database),
                  let intellectualProperty = try await BlogPost.find(UUID(uuidString: "bc561082-a34b-4a53-8877-dec62d28ffd8"), on: database),
                  let makingThisBlog = try await BlogPost.find(UUID(uuidString: "7bc345f7-1587-4fdd-885c-ad254890f67e"), on: database),
                  let passionAndPurpose = try await BlogPost.find(UUID(uuidString: "b51b5885-d3f5-4082-b634-383cd90443ab"), on: database),
                  let automatedTesting = try await BlogPost.find(UUID(uuidString: "798d115c-4268-4236-84e9-d290f47cf450"), on: database),
                  let visionPro = try await BlogPost.find(UUID(uuidString: "5675d0e5-f69d-4b89-a642-6d6ac979ce83"), on: database),
                  let wwdc2022 = try await BlogPost.find(UUID(uuidString: "274feaf9-5219-4d3d-9c09-6e8620e52db2"), on: database) else { return }
            try await openFGAService.createRelation(client: client,
                                                    OpenFGATuple(user: tyler, relation: .admin, object: System.global),
                                                    OpenFGATuple(user: System.global, relation: .system, object: restNetworkingLayer),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: restNetworkingLayer),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: restNetworkingLayer),
                                                    OpenFGATuple(user: tyler, relation: .author, object: restNetworkingLayer),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingCost),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingCost),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingCost),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingCost),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingProximity),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingProximity),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingProximity),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingProximity),
                                                    OpenFGATuple(user: System.global, relation: .system, object: intellectualProperty),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: intellectualProperty),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: intellectualProperty),
                                                    OpenFGATuple(user: tyler, relation: .author, object: intellectualProperty),
                                                    OpenFGATuple(user: System.global, relation: .system, object: makingThisBlog),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: makingThisBlog),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: makingThisBlog),
                                                    OpenFGATuple(user: tyler, relation: .author, object: makingThisBlog),
                                                    OpenFGATuple(user: System.global, relation: .system, object: passionAndPurpose),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: passionAndPurpose),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: passionAndPurpose),
                                                    OpenFGATuple(user: tyler, relation: .author, object: passionAndPurpose),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTesting),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTesting),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTesting),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTesting),
                                                    OpenFGATuple(user: System.global, relation: .system, object: visionPro),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: visionPro),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: visionPro),
                                                    OpenFGATuple(user: tyler, relation: .author, object: visionPro),
                                                    OpenFGATuple(user: System.global, relation: .system, object: wwdc2022),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: wwdc2022),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: wwdc2022),
                                                    OpenFGATuple(user: tyler, relation: .author, object: wwdc2022)
            )
        }
    }
    
    func revert(on database: any Database) async throws {
        try await withContainer(container) {
            let prodTyler = try await User.find(UUID(uuidString: "c6b2b5d9-cfcf-4d5d-b818-12d9e4fcd6c3"), on: database)
            let debugTyler = try await User.find(UUID(uuidString: "6D50873A-D6EE-4B1E-9ADF-99067B2B4467"), on: database)
            guard let tyler = prodTyler ?? debugTyler else { return }
            guard let restNetworkingLayer = try await BlogPost.find(UUID(uuidString: "b35c209e-d2c1-475b-86af-333294c9407e"), on: database),
                  let automatedTestingUndesirableChange = try await BlogPost.find(UUID(uuidString: "1665046f-18ba-4005-9122-b708a28640dc"), on: database),
                  let automatedTestingDesirableChange = try await BlogPost.find(UUID(uuidString: "de43ae83-2feb-4b2f-9a7d-25f6078fb547"), on: database),
                  let automatedTestingCost = try await BlogPost.find(UUID(uuidString: "fa44f008-9f2e-4152-af22-c9359d1d206c"), on: database),
                  let automatedTestingFalseNegative = try await BlogPost.find(UUID(uuidString: "4d4b70cc-1bbd-4505-a40e-33376d494302"), on: database),
                  let automatedTestingFalsePositive = try await BlogPost.find(UUID(uuidString: "fde72d71-6b59-49a6-bca5-419c12835348"), on: database),
                  let automatedTestingProximity = try await BlogPost.find(UUID(uuidString: "733037c5-960e-4ed8-8190-d1fd72fb24d6"), on: database),
                  let intellectualProperty = try await BlogPost.find(UUID(uuidString: "bc561082-a34b-4a53-8877-dec62d28ffd8"), on: database),
                  let makingThisBlog = try await BlogPost.find(UUID(uuidString: "7bc345f7-1587-4fdd-885c-ad254890f67e"), on: database),
                  let passionAndPurpose = try await BlogPost.find(UUID(uuidString: "b51b5885-d3f5-4082-b634-383cd90443ab"), on: database),
                  let automatedTesting = try await BlogPost.find(UUID(uuidString: "798d115c-4268-4236-84e9-d290f47cf450"), on: database),
                  let visionPro = try await BlogPost.find(UUID(uuidString: "5675d0e5-f69d-4b89-a642-6d6ac979ce83"), on: database),
                  let wwdc2022 = try await BlogPost.find(UUID(uuidString: "274feaf9-5219-4d3d-9c09-6e8620e52db2"), on: database) else { return }
            try await openFGAService.deleteRelation(client: client,
                                                    OpenFGATuple(user: tyler, relation: .admin, object: System.global),
                                                    OpenFGATuple(user: System.global, relation: .system, object: restNetworkingLayer),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: restNetworkingLayer),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: restNetworkingLayer),
                                                    OpenFGATuple(user: tyler, relation: .author, object: restNetworkingLayer),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingUndesirableChange),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingDesirableChange),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingCost),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingCost),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingCost),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingCost),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingFalseNegative),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingFalsePositive),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTestingProximity),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTestingProximity),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTestingProximity),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTestingProximity),
                                                    OpenFGATuple(user: System.global, relation: .system, object: intellectualProperty),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: intellectualProperty),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: intellectualProperty),
                                                    OpenFGATuple(user: tyler, relation: .author, object: intellectualProperty),
                                                    OpenFGATuple(user: System.global, relation: .system, object: makingThisBlog),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: makingThisBlog),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: makingThisBlog),
                                                    OpenFGATuple(user: tyler, relation: .author, object: makingThisBlog),
                                                    OpenFGATuple(user: System.global, relation: .system, object: passionAndPurpose),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: passionAndPurpose),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: passionAndPurpose),
                                                    OpenFGATuple(user: tyler, relation: .author, object: passionAndPurpose),
                                                    OpenFGATuple(user: System.global, relation: .system, object: automatedTesting),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: automatedTesting),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: automatedTesting),
                                                    OpenFGATuple(user: tyler, relation: .author, object: automatedTesting),
                                                    OpenFGATuple(user: System.global, relation: .system, object: visionPro),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: visionPro),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: visionPro),
                                                    OpenFGATuple(user: tyler, relation: .author, object: visionPro),
                                                    OpenFGATuple(user: System.global, relation: .system, object: wwdc2022),
                                                    OpenFGATuple(user: .init(type: "user", id: "*"), relation: .viewer, object: wwdc2022),
                                                    OpenFGATuple(user: .init(type: "guest", id: "*"), relation: .viewer, object: wwdc2022),
                                                    OpenFGATuple(user: tyler, relation: .author, object: wwdc2022)
            )
        }
    }
}
