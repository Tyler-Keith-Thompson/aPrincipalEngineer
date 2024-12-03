//
//  QueueInMemoryDriver.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

#if DEBUG

import NIOConcurrencyHelpers
import NIOCore
import Queues
import Vapor

extension Application.Queues.Provider {
    static var memory: Self {
        .init {
            $0.queues.initializeInMemoryStorage()
            return $0.queues.use(custom: InMemoryQueuesDriver())
        }
    }
}

struct InMemoryQueuesDriver: QueuesDriver {
    init() {}
    func makeQueue(with context: QueueContext) -> any Queue { InMemoryQueue(_context: .init(context)) }
    func shutdown() {}
}

extension Application.Queues {
    final class InMemoryQueueStorage: Sendable {
        private struct Box: Sendable {
            var jobs: [JobIdentifier: JobData] = [:]
            var queue: [JobIdentifier] = []
        }

        private let box = NIOLockedValueBox<Box>(.init())

        var jobs: [JobIdentifier: JobData] {
            get { box.withLockedValue { $0.jobs } }
            set { box.withLockedValue { $0.jobs = newValue } }
        }

        var queue: [JobIdentifier] {
            get { box.withLockedValue { $0.queue } }
            set { box.withLockedValue { $0.queue = newValue } }
        }
    }

    struct InMemoryQueueKey: StorageKey, LockKey {
        typealias Value = InMemoryQueueStorage
    }

    var memory: InMemoryQueueStorage {
        application.storage[InMemoryQueueKey.self]!
    }

    func initializeInMemoryStorage() {
        application.storage[InMemoryQueueKey.self] = .init()
    }
}

struct InMemoryQueue: AsyncQueue {
    enum Error: Swift.Error {
        case jobNotFound
    }
    
    let _context: NIOLockedValueBox<QueueContext>
    var context: QueueContext { _context.withLockedValue { $0 } }

    func get(_ id: JobIdentifier) async throws -> JobData {
        guard let jobData = _context.withLockedValue({ $0.application.queues.memory.jobs[id] }) else {
            throw Error.jobNotFound
        }
        return jobData
    }
    
    func set(_ id: JobIdentifier, to data: JobData) async throws {
        _context.withLockedValue { $0.application.queues.memory.jobs[id] = data }
    }
    
    func clear(_ id: JobIdentifier) async throws {
        _context.withLockedValue { $0.application.queues.memory.jobs[id] = nil }
    }
    
    func pop() async throws -> JobIdentifier? {
        _context.withLockedValue { $0.application.queues.memory.queue.popLast() }
    }
    
    func push(_ id: JobIdentifier) async throws {
        _context.withLockedValue { $0.application.queues.memory.queue.append(id) }
    }
}

#endif
