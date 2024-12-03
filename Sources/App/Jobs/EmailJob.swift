//
//  EmailJob.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Vapor
import Foundation
import Queues
import SendGrid
import DependencyInjection

struct EmailJob: AsyncJob {
    let container = Container.current
    @Injected(Container.emailService) private var emailService
    
    typealias Payload = SendGridEmail<[String: String]>

    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        try await withContainer(container) {
            try await emailService.send(context: context, email: payload)
        }
    }
}
