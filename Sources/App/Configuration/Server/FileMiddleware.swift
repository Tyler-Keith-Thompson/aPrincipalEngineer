//
//  FileMiddleware.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import DependencyInjection
import Vapor

extension Container {
    protocol FileMiddlewareFactory {
        func middleware(for: Application) -> FileMiddleware
    }
#if DEBUG && Xcode
    struct DebugFileMiddlewareFactory: FileMiddlewareFactory {
        func middleware(for _: Application) -> FileMiddleware {
            FileMiddleware(publicDirectory: Bundle.module.bundleURL.appendingPathComponent("Contents/Resources/Public").path)
        }
    }
#endif
    struct ProductionFileMiddlewareFactory: FileMiddlewareFactory {
        func middleware(for app: Application) -> FileMiddleware {
            FileMiddleware(publicDirectory: app.directory.publicDirectory)
        }
    }
    static let fileMiddlewareFactory = Factory { () -> any FileMiddlewareFactory in
#if DEBUG && Xcode
        DebugFileMiddlewareFactory()
#else
        ProductionFileMiddlewareFactory()
#endif
    }
}
