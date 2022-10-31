---
date: 2022-10-30 11:30
description: I walk through my favorite REST networking layer, and why I prefer it.
tags: engineering, testing, swift
author: Tyler Thompson
title: A Great REST Networking Layer
---

## Motivation
A great networking layer is hard to come by. Some people pull in 3rd party dependencies with interceptors and lots of layers of abstraction, some just use `URLSession` and GCD. I personally don't like either option, at least for simple REST calls. This article will be a bit long, but I'll walk you through my preferred networking layer and explain why I like it.

> NOTE: All code for this example can be found [on my github random projects page](https://github.com/Tyler-Keith-Thompson/RandomSideProjects/tree/main/RESTNetworkLayer)

## GCD, Combine, or Async/Await
Let's be honest, Grand Central Dispatch (GCD) is kind of a mess. The closure-based APIs aren't very friendly and they're error-prone. Most people who write asynchronous operations using GCD don't even consider cancellation. GCD's quirkiness is why you see network layers with interceptor patterns. This was fine a few years ago, but I think we can do better.

`async/await` is [fraught](https://wojciechkulik.pl/ios/swift-concurrency-things-they-dont-tell-you?utm_campaign=iOS%2BDev%2BWeekly&utm_medium=web&utm_source=iOS%2BDev%2BWeekly%2BIssue%2B582) [with](https://swiftsenpai.com/swift/actor-reentrancy-problem/) [perils](https://alejandromp.com/blog/the-importance-of-cooperative-cancellation/) and people don't often immediately notice them. This is especially true with the cooperative cancellation paradigm, which requires you to be smart about checking whether a task has been cancelled frequently (ideally, after every `await` boundary).

This is why I prefer Combine, Apple's reactive framework. Its declarative interface, cancellation model, and flexibility with back-pressure is incredibly useful when designing a networking layer. I would argue that it is still preferrable to `async/awati`. Although I would use `async/await` for on-device concurrency concerns.

What's more, Combine forces users to store an `AnyCancellable` and most common methods of storing them result in appropriate cancellation. For example, if you store a `Set<AnyCanellable>` on a `UIViewController` or SwiftUI `@StateObject`, they are all cancelled when the view is removed from the hierarchy. So, if a user were to hit the "back" button in a navigation stack, for example, all ongoing requests for that view would simply cancel.

## Service design
Ideally, other parts of the code utilize the network layer [through a service](https://en.wikipedia.org/wiki/Service_(systems_architecture)). For example, if I had an API that stored and retreived posts on a forum, I'd create a `PostService` which returned deserialized `Post` objects. Other parts of my code would ask the `PostService` for things, and it would either reach out over the network, or pull from a cache, or any other number of things.

To that end, our network layer should make it easy for a service to use it with extreme flexibility, but not expose things outside of those services. I think a protocol is a great way of handling this. What if we had something like this:

```
protocol PostService {
    var getPosts: AnyPublisher<Result<[Post], Error>, Never> { get }
}

struct _PostService: RESTAPIProtocol, PostService {
    var baseURL = "https://api.myforum.com"
    var getPosts: AnyPublisher<Result<[Post], Error>, Never> {
        self.get(endpoint: "posts") { request in 
            request
            .addingBearerAuthorization(accessToken: User.shared.accessToken)
            .receivingJSON()
        }
        .catchHTTPErrors()
        .catchUnauthorizedAndRetryRequestWithFreshAccessToken()
        .map(\.data)
        .decode(type: [Post].self, decoder: JSONDecoder())
        .map(Result.success)
        .catch { Just(.failure($0)) }
        .eraseToAnyPublisher()
    }
}
```

Consumers only know about `PostService` which exposes a way to get posts, but the service itself (`_PostService`) knows lots of details, like the base uRL, endpoint, the fact it needs authentication, it can handle back-pressure issues like receiving a 401 and retrying the request, it knows we're using REST and JSON and it knows how to deserialize into an array of `Post`. 

## Creating a RESTAPIProtocol
One quirk of making requests with Swift is that you get a `URLResponse` which needs to be converted into an `HTTPURLResponse` to check things like the status code. To make this easier, our protocol should return an `HTTPURLResponse`.

Let's start with a simple protocol definition:
```
import Foundation
import Combine

public protocol RESTAPIProtocol {
    typealias ErasedHTTPDataTaskPublisher = AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    typealias Output = ErasedHTTPDataTaskPublisher.Output
    typealias Failure = ErasedHTTPDataTaskPublisher.Failure

    var baseURL: String { get }
    var urlSession: URLSession { get }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 7.0, *)
extension RESTAPIProtocol {
    public var urlSession: URLSession { URLSession.shared }

    public func get(endpoint: String) -> ErasedHTTPDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<Output, Failure>(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return createPublisher(for: request)
    }

    // Other verbs, put/post/patch/delete

    func createPublisher(for request: URLRequest) -> ErasedHTTPDataTaskPublisher {
        Just(request)
            .flatMap { [urlSession] in
                urlSession.dataTaskPublisher(for: $0)
            }
            .tryMap {
                guard let res = $0.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return (data: $0.data, response: res)
            }
            .eraseToAnyPublisher()
    }
}
```

Our protocol now exposes a way to make `GET` requests...but it doesn't allow people to modify the outgoing request. Consumers of our protocol want 2 specific behaviors:

- The ability to modify a request before it is sent.
- If the pubslisher retries (like when a 401 is returned) then the request modifier should be recalculated.
    - To expand on this idea, look at the example in our `PostService` when the publisher chain restarts the *new* access token needs to be used, not the old one.

Because `Just` is a little fiddly, anything we put int here will be cached, we need to be a little bit clever. Let's modify `RESTAPIProtocol`

```
public protocol RESTAPIProtocol {
    typealias RequestModifier = ((URLRequest) -> URLRequest)
    ...
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 7.0, *)
extension RESTAPIProtocol {
    ...

    public func get(endpoint: String, requestModifier: @escaping RequestModifier = { $0 }) -> ErasedHTTPDataTaskPublisher {
        ...
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    func createPublisher(for request: URLRequest, requestModifier: @escaping RequestModifier) -> ErasedHTTPDataTaskPublisher {
        Just(request)
            .flatMap { [urlSession] in
                urlSession.dataTaskPublisher(for: requestModifier($0))
            }
            ...
    }
}
```

Now consumers can modify a request just like our `PostService` example. Calculating the `requestModifier` in the `flatMap` gives us the behavior we want when the chain is restarted.

## Fluent request modification
You may have noticed that in my proposed service, we used a [fluent API](https://en.wikipedia.org/wiki/Fluent_interface#Swift). This not only fits well with Combine, which is already fluent, but it makes it easy to compose sets of headers. Here's how we can do that:

```
extension URLRequest {
    public func addingValue(_ value: String, forHTTPHeaderField header: String) -> URLRequest {
        var request = self
        request.setValue(value, forHTTPHeaderField: header)
        return request
    }
}
```

This also has the advantage of not mutating the original request, avoiding mutation where we can is generally of great benefit. You'll notice the existing `URLRequest` is copied into a new variable, then *that* is modified using Apple APIs.

## Error handling
We can create a series of `HTTPError` types, some for 400-499 `HTTPClientError` types and some for 500-599 `HTTPServerError` types. These can even peak into a request and find standard headers that give more error info. For example, a 429 usually comes with a `Retry-After` header indicating how long you should wait before attempting the request again.

Once those errors types are created, we can create a combine modifier that handles them, here's an example:

```
extension Publisher {
    public func catchHTTPErrors() -> Publishers.TryMap<Self, Output> where Output == RESTAPIProtocol.Output {
        tryMap {
            guard let err: any HTTPError = HTTPClientError(code: UInt($0.response.statusCode)) ?? HTTPServerError(code: UInt($0.response.statusCode)) else {
                return $0
            }

            if $0.response.statusCode == 429 {
                throw HTTPClientError.tooManyRequests(retryAfter: $0.response.retryAfter)
            }

            throw err
        }
    }
}
```

Users may also want to be able to catch specific kinds of errors, which Combine doesn't quite allow on its own. This gives them the ability to add custom logic on the request chain. Here's an example that responds to rate limiting (a 429)

```
extension Publisher {
    public func tryCatch<E: Error & Equatable,
                         P: Publisher>(_ error: E,
                                       _ handler: @escaping (E) throws -> P) -> Publishers.TryCatch<Self, P> where Failure == Error {
        tryCatch { err in
            guard let unwrappedError = (err as? E),
                    unwrappedError == error else { throw err }
            return try handler(unwrappedError)
        }
    }

    public func respondToRateLimiting(maxSecondsToWait: Double = 1) -> AnyPublisher<Output, Failure> where Output == RESTAPIProtocol.Output, Failure == Error {
        catchHTTPErrors()
            .tryCatch(HTTPClientError.tooManyRequests()) { err -> AnyPublisher<Output, Failure> in
                guard case .tooManyRequests(let retryAfter) = err else {
                    throw err // shouldn't ever really happen
                }

                let delayInSeconds: Double = {
                    if let serverDelay = retryAfter?.converted(to: .seconds).value,
                       serverDelay < maxSecondsToWait {
                        return serverDelay
                    }
                    return maxSecondsToWait
                }()

                return Just(()).delay(for: .seconds(delayInSeconds),
                                      scheduler: DispatchQueue.global(qos:.userInitiated),
                                      options: nil)
                .flatMap { _ in self.catchHTTPErrors() }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
```

There's a few complicated combine type things to learn, but look at just how easy it is to handle rate limiting! No interceptors and complex retry logic, just a simple combination of existing Combine operators. I'll leave it as an exercise to the reader to imagine how you could add even more flexibility (like retrying on a 401) to this. Alternatively, check out [the github repo](https://github.com/Tyler-Keith-Thompson/RandomSideProjects/tree/main/RESTNetworkLayer) to see an example.

## Testing
Okay, so while reactive programming might be new to people, this whole layer isn't too intimidating. But how hard is it to test? I personally use [OHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) and create my own [fluent wrapper around it](https://github.com/AliSoftware/OHHTTPStubs/issues/349) to make this dead simple.

Let's start by defining a combine test helper:
```
extension Publisher {
    func firstValue(timeout: TimeInterval = 0.3,
                    file: StaticString = #file,
                    line: UInt = #line) async -> Result<Output, Error> where Failure == Error {
        await withCheckedContinuation { continuation in
            var result: Result<Output, Error>?
            let expectation = XCTestExpectation(description: "Awaiting publisher")

            let cancellable = map(Result<Output, Error>.success)
                .catch { Just(.failure($0)) }
                .sink {
                    result = $0
                    expectation.fulfill()
                }

            XCTWaiter().wait(for: [expectation], timeout: timeout)
            cancellable.cancel()

            do {
                let unwrappedResult = try XCTUnwrap(
                    result,
                    "Awaited publisher did not produce any output",
                    file: file,
                    line: line
                )
                continuation.resume(returning: unwrappedResult)
            } catch {
                continuation.resume(returning: .failure(error))
            }
        }
    }
}
```

Now I'll show you how easy it is to test our rate limiting logic:
```
import Foundation
import Combine
import XCTest

import OHHTTPStubs
import OHHTTPStubsSwift

import RESTNetworkLayer

final class HTTPOperatorsTests: XCTestCase {
    struct JSONPlaceholder: RESTAPIProtocol {
        var baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    override func setUpWithError() throws {
        HTTPStubs.removeAllStubs()

        stub { _ in true } response: { req in
            XCTFail("Unexpected request made: \(req)")
            return HTTPStubsResponse(error: URLError.init(.badURL))
        }
    }

    func testCatchingTooManyRequests() async throws {
        let url = try XCTUnwrap(URL(string: "https://www.google.com"))

        let error = HTTPClientError.tooManyRequests()

        let response = try XCTUnwrap(HTTPURLResponse(url: url,
                                                     statusCode: Int(error.statusCode),
                                                     httpVersion: nil,
                                                     headerFields: ["Retry-After": "1.5"]))

        let result = await Just((data: Data(), response: response))
            .setFailureType(to: Error.self)
            .catchHTTPErrors()
            .firstValue()

        guard case .failure(let failure) = result else {
            XCTFail("Publisher succeeded, expected failure with HTTPError")
            return
        }

        guard let actualError = failure as? (any HTTPError) else {
            XCTFail("Error: \(failure) thrown by publisher was not an HTTPError")
            return
        }

        XCTAssertEqual(actualError.statusCode, error.statusCode)

        if case HTTPClientError.tooManyRequests(.some(let retryAfter)) = actualError {
            XCTAssertEqual(retryAfter.converted(to: .seconds).value, 1.5)
        } else {
            XCTFail("RetryAfter value not in error.")
        }
    }

    func testRetryAfterServerSpecifiedTime() async throws {
        let json = try XCTUnwrap("""
        [
            {
                userId: 1,
                id: 1,
                title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
            },
        ]
        """.data(using: .utf8))
        let retryAfter = Double.random(in: 0.100...0.240)
        let requestDate: Date = Date()
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }
        .thenRespond(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: json, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.get(endpoint: "posts")
            .respondToRateLimiting()
            .firstValue()
            .get()

        XCTAssertGreaterThan(Date().timeIntervalSince1970 - requestDate.timeIntervalSince1970, Measurement(value: retryAfter, unit: UnitDuration.milliseconds).converted(to: .seconds).value)
        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
    }

    func testRespondToRateLimitingOnlyRetriesOnce() async throws {
        let retryAfter = Double.random(in: 0.100...0.300)
        let requestDate: Date = Date()
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }
        .thenRespond(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }
        .thenRespond(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            XCTFail("Should not have made a 3rd request")
            return HTTPStubsResponse(data: Data(), statusCode: Int32(HTTPClientError.tooManyRequests().statusCode), headers: ["Retry-After": "\(retryAfter)"])
        }

        let api = JSONPlaceholder()

        var publisherRetries = 0
        let result = await api.get(endpoint: "posts")
            .map { val in
                publisherRetries += 1
                return val
            }
            .respondToRateLimiting(maxSecondsToWait: 0)
            .firstValue()

        XCTAssertGreaterThan(Date().timeIntervalSince1970 - requestDate.timeIntervalSince1970, Measurement(value: retryAfter, unit: UnitDuration.milliseconds).converted(to: .seconds).value)
        XCTAssertThrowsError(try result.get()) { error in
            guard let actualError = error as? (any HTTPError) else {
                XCTFail("Error: \(error) thrown by publisher was not an HTTPError")
                return
            }

            XCTAssertEqual(actualError.statusCode, HTTPClientError.tooManyRequests().statusCode)
        }
        XCTAssertEqual(publisherRetries, 2)
    }

    func testRateLimitingShouldDoNothingUnlessCorrectStatusCodeIsGiven() async throws {
        let json = try XCTUnwrap("""
        [
            {
                userId: 1,
                id: 1,
                title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
            },
        ]
        """.data(using: .utf8))
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            HTTPStubsResponse(data: json, statusCode: 200, headers: nil)
        }

        let api = JSONPlaceholder()

        let value = try await api.get(endpoint: "posts")
            .respondToRateLimiting()
            .firstValue()
            .get()

        XCTAssertEqual(value.response.statusCode, 200)
        XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
    }

    func testRateLimitingDoesNotRetryIfADifferentErrorIsThrown() async throws {
        var requestCount = 0
        StubResponse(on: isAbsoluteURLString("https://jsonplaceholder.typicode.com/posts") && isMethodGET()) { _ in
            requestCount += 1
            return HTTPStubsResponse(data: Data(), statusCode: 401, headers: nil)
        }

        let api = JSONPlaceholder()

        let result = await api.get(endpoint: "posts")
            .respondToRateLimiting()
            .firstValue()

        XCTAssertThrowsError(try result.get()) {
            XCTAssertEqual($0 as? HTTPClientError, .unauthorized)
        }

        XCTAssertEqual(requestCount, 1)
    }
}
```

There may be a lot of code, but each test is actually quite simple and understandable.

## Wrapping up
It's fair to say this probably isn't a beginner level networking layer. But the power and flexibility of Combine, coupled with the cancellation model make it a really useful tool. This article certainly didn't cover all the details, check out [the git repo](https://github.com/Tyler-Keith-Thompson/RandomSideProjects/tree/main/RESTNetworkLayer) to see even more of how it all came together. 