import Vapor

extension RoutesBuilder {
    @discardableResult
    @preconcurrency
    public func get<Response>(
        _ path: PathComponent...,
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.GET, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func get<Response>(
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.GET, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func post<Response>(
        _ path: PathComponent...,
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.POST, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func post<Response>(
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.POST, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func patch<Response>(
        _ path: PathComponent...,
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.PATCH, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func patch<Response>(
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.PATCH, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func put<Response>(
        _ path: PathComponent...,
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.PUT, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func put<Response>(
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.PUT, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func delete<Response>(
        _ path: PathComponent...,
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.DELETE, path, body: body, use: closure)
    }
    
    @discardableResult
    @preconcurrency
    public func delete<Response>(
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy,
        use closure: @Sendable @escaping (Request) async throws -> Response
    ) -> Route
    where Response: AsyncResponseEncodable
    {
        return self.on(.DELETE, path, body: body, use: closure)
    }
}
