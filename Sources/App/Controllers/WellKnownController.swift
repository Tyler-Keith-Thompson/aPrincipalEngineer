//
//  WellKnownController.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Vapor

struct WellKnownController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let wellKnown = routes.grouped(".well-known")
        wellKnown.get("apple-app-site-association", use: self.getAppleSiteAssociation)
    }

    @Sendable
    func getAppleSiteAssociation(req: Request) async throws -> AppleSiteAssociation {
        return AppleSiteAssociation(
            applinks: .init(details: [
                .init(appIDs: [], components: [])
            ]),
            webcredentials: .init(apps: [])
        )
    }
}

extension WellKnownController {
    struct AppleSiteAssociation: Content {
        struct AppLinks: Content {
            struct Detail: Content {
                let appIDs: [String]
                let components: [String]
            }
            
            let details: [Detail]
        }
        struct WebCredentials: Content {
            let apps: [String]
        }
        let applinks: AppLinks
        let webcredentials: WebCredentials
    }
}
