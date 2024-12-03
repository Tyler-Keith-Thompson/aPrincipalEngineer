//
//  entrypoint.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Vapor
import Logging
import NIOCore
import NIOPosix
import Metrics
import SystemMetrics
import Prometheus
import OTel
import OTLPGRPC
import Tracing
import ServiceLifecycle

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env) { level in
            let console = Terminal()
            return { (label: String) in
                return MultiplexLogHandler([
                    ConsoleLogger(label: label, console: console, level: level, metadataProvider: .otel),
                ])
            }
        }
        
        // Configure OTel resource detection to automatically apply helpful attributes to events.
        let environment = OTelEnvironment.detected()
        let resourceDetection = OTelResourceDetection(detectors: [
            OTelProcessResourceDetector(),
            OTelEnvironmentResourceDetector(environment: environment),
            .manual(OTelResource(attributes: ["aPrincipalEngineer": "aprincipalengineer_server"])),
        ])
        let resource = await resourceDetection.resource(environment: environment, logLevel: .trace)
        
        // Bootstrap the metrics backend to export metrics periodically in OTLP/gRPC.
        let registry = OTelMetricRegistry()
        let metricsExporter = try OTLPGRPCMetricExporter(configuration: .init(environment: environment))
        let metrics = OTelPeriodicExportingMetricsReader(
            resource: resource,
            producer: registry,
            exporter: metricsExporter,
            configuration: .init(environment: environment)
        )
        MetricsSystem.bootstrapWithSystemMetrics(
            MultiplexMetricsHandler(factories: [
                OTLPMetricsFactory(registry: registry),
                PrometheusMetricsFactory()
            ]),
            config: .init(labels: .init(prefix: "aprincipalengineer_server+",
                                        virtualMemoryBytes: "vmb",
                                        residentMemoryBytes: "rmb",
                                        startTimeSeconds: "sts",
                                        cpuSecondsTotal: "cpt",
                                        maxFds: "mfd",
                                        openFds: "ofd",
                                        cpuUsage: "cpu")))
        
        // Bootstrap the tracing backend to export traces periodically in OTLP/gRPC.
        let exporter = try OTLPGRPCSpanExporter(configuration: .init(environment: environment))
        let processor = OTelBatchSpanProcessor(exporter: exporter, configuration: .init(environment: environment))
        let tracer = OTelTracer(
            idGenerator: OTelRandomIDGenerator(),
            sampler: OTelConstantSampler(isOn: true),
            propagator: OTelW3CPropagator(),
            processor: processor,
            environment: environment,
            resource: resource
        )
        InstrumentationSystem.bootstrap(tracer)
        
        let app = try await Application.make(env)

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
        // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
        // If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
        let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
        app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])
        
        let group = ServiceGroup(services: [metrics], logger: app.logger)
        do {
            // Otel isn't reporting anywhere, don't actually run it until configured
//            Task { try await group.run() }
            try await configure(app)
        } catch {
            app.logger.report(error: error)
            await group.triggerGracefulShutdown()
            try? await app.asyncShutdown()
            throw error
        }
        try await app.execute()
        await group.triggerGracefulShutdown()
        try await app.asyncShutdown()
    }
}
