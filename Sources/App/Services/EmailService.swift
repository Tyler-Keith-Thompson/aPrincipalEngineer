//
//  EmailService.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Afluent
import Queues
import DependencyInjection
import SendGrid

protocol EmailService {
    func send<T: Codable & Sendable>(context: QueueContext, email: SendGridEmail<T>) async throws
}

final class _EmailService: EmailService, @unchecked Sendable {
    let cache = AUOWCache()
    func send<T: Codable & Sendable>(context: QueueContext, email: SendGridEmail<T>) async throws {
        try await context.application.sendgrid.client.send(email: email)
    }
}

#if DEBUG
final class _DebugEmailService: EmailService, @unchecked Sendable {
    let cache = AUOWCache()
    func send<T: Codable & Sendable>(context: QueueContext, email: SendGridEmail<T>) async throws {
        print(email)
    }
}
#endif

extension Container {
    // basically only in-memory while it's doing something
    static let emailService = Factory(scope: .shared) { () -> any EmailService in
#if DEBUG
        return _DebugEmailService()
#else
        return _EmailService()
#endif
    }
}
