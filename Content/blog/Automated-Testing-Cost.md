---
date: 2022-07-18 1:30
description: Learn how to minimize cost when writing automated tests. Learn about the different kinds of tests you might write and where to invest your time.
tags: engineering, testing
author: Tyler Thompson
title: Automated Testing: Cost
---

## The cost principal
**Cost**: This is often measured in time. If two tests harnesses prove the same thing, but one executes in a few seconds and the other in a few minutes, prefer the one that executes faster. Fast tests give developers immediate feedback and are more likely to be run repeatedly.

## Disambiguating testing terminology
The way we refer to automated tests is very ambiguous. Let's start by identifying some terminology and strategies for writing tests. 

#### Unit tests
One of my favorite questions to ask somebody who writes automated tests is "What is a unit?" This is a puzzler for so many people, so let me clearly describe it here. A unit is a single interface, now some languages have a nominal type called `Interface` where you define an abstraction layer...that's not what I mean. Every structure in code has an interface of some kind, it has an internal interface and sometimes a public interface. For example:

```swift
public struct MyStruct {
    let property = "someProperty"

    func someFunc() { }

    public func somePublicFunc() { }

    private func somePrivateFunc() { }
}
```

The preceeding example has an internal and a public interface. The internal interface has a property called `property` and a function called `someFunc`. These are a unit. It also has a public interface that has `somePublicFunc`, that is also a unit. This didn't use an `Interface` (or in Swift, a `Protocol`) but it still has an interface. Other parts of the codebase will call the internal functions and external consumers will call the public method. A series of unit tests should be written to cover each interface. 

The private method in this example is not part of the unit and it should not be tested. Testing private method tightly couples your tests to implementation details, it doesn't matter what a private method does or how many private methods there are. What matters is when you use an interface there's a desired result. When a consumer calls `someFunc` they have an expectation of behavior. Our tests should assert what that expectation is.

#### Sociable tests
Martin Fowler wrote an excellent article on [Sociable Testing](https://martinfowler.com/bliki/UnitTest.html). In it he coins the terms *Solitary* and *Sociable* when referring to unit tests. A solitary unit test is one that isolates all collaborators. In other words, if one structure (class/struct/etc) depends on another, you create a test double for that dependency. Sociable tests assume that other collaborators work, and do not isolate the unit. 

I'll take a strong stance here and suggest that this is where you should invest your time and effort. Sociable unit tests allow for great refactoring without worrying about implementation details. There are still times when you need to inject a test double, for example if your structure makes a remote network call you might want to stub network responses. However, if you assume other dependencies work you can still pinpoint issues but more importantly refactors don't cause tests to break for the wrong reasons.

Sociable tests are still unit tests because you're still testing a unit, you want to ensure that some interface, when invoked, behaves according to expectations. That said, when you write sociable tests it may not be necessary to write them for every unit of production code. If we take this to the extreme you could write tests that perform actions as if a User had, and then assert on the expected behavior. Allowing whatever architecture you desire to exist and be refactored.

[ViewInspector](https://github.com/nalexn/ViewInspector) is a library I use for testing SwiftUI. It is SwiftUI unit testing, they're fast and effective, but they perform actions much like a user would. It can do hit testing and check on view state, like whether a button is enabled. You can write tests that set up preconditions, perform actions like a user would, then assert on expected behavior. Any implementation details about what structures exist in the production code are irrelevant. [UIUTest](https://github.com/nallick/UIUTest) is a library that does the same, but for UIKit.

#### Mocks, stubs, and spies.
A spy is a test double that reports back on interactions on a unit. So if you had a function `doSomething` a spy would report how many times `doSomething` was called and with what parameters. A stub is a structure that returns canned responses. If `doSomething` returns a `String` you could write a stub that said when `doSomething` is called, return some test value. These are great for creating a test double of a dependency. A Mock is much like a stub, except like a spy, it can verify interactions. For example, a mock can stub a response and verify whether `doSomething` was called and with which parameters.

Spies can often be a code smell, they can indicate that you're relying on implementation details. Stubs and mocks can be incredibly powerful tools for ensuring your test suite doesn't rely on external dependencies. For example, you'll frequently stub your network layer when writing unit tests. You'll also mock things like a database, because you don't want your unit tests creating any persistent state.

Mocks, stubs, and spies should all be used in conjunction to remove side-effects from testing. Your tests should be atomic, in other words every time you run them they should produce the same results. If unit tests are writing files, or entries to a database, or making network calls then your tests will likely not be atomic, the second time your run them they may produce different results. This is not at all desirable.

#### Contract tests
Unit tests are the cheapest kind of tests, they're amazingly fast and very reliable. If you can prove everything you need to with unit tests, you should not write other kinds of tests. That said, often times a system you're writing will communicate with others. In these cases you are relying on those external systems to respond in a particular way. Contract tests are a simple way of determining whether an external system is adhering to the agreed upon contract. [Pact.io](https://pact.io) is a wonderful example of a contract testing framework that works asynchronously. Their tagline changed in recent years and they claim to be an integration testing framework, but I think they're still far more suited to contract testing. There are other services, like [Wiremock](https://wiremock.org/) that are also useful for contract testing. 

Using a service like pact is great because it validates both systems are adhering to the contract. Wiremock could be useful, but might also be achievable with a simple HTTP stubbing library. Either way your system makes assumptions about a contract, these tests document those assumptions and asser that they're correct.

#### Integration tests
Integration tests are more expensive that contract tests. If you can prove all you need to with unit and contract tests, you can avoid writing integration tests. That said, sometimes verifying a contract is met isn't enough. For example, if your system depends not only on the contract being correct but also observable behavior being correct in a different system. An example might be creating a resource, then deleting that resource behaves as expected. 

While there are integration testing tools a lot of them start violating the principal of proximity to your code. For example you can maintain postman scripts for integration testing, but those aren't as close to your production code as another test target that performs network calls would be. I recommend writing integration tests simply, in the same language you wrote your production code in.

If it's at all possible create ephemeral versions of your external dependencies. In other words, if you're writing a mobile app's integration tests you would be better off starting a docker container with an API your app depends on and testing against that over the local network than actually hitting a production or pre-production hosted version of that API. This puts your tests in closer proximity to your code and it reduces a lot of noise for issues like network latency and bandwidth constraints. 

#### End-to-end tests
End to end tests are the most expensive kind of tests you can write. These should be incredibly limited. End-to-end tests should be thought of more as a sanity check than anything else. They should cover only your critical features and shouldn't test edge cases, but instead should test what most users of your system will do. In order to execute an End-to-end (e2e) test you have to stand up every part of your environment and test through it. 

Once again, you're better off if you can stand up your entire environment in an ephemeral way. For example, using something like docker compose to stand up a version of every microservice in an environment and a database. After the test is over these can all be destroyed. This isolates you as best as possible from noisy and irrelevant conditions, like a different team working on a service and it not being available at that moment.

If your e2e testing suite is the only one that catches a legitimate problem this should be a major red flag. The expectation is that unit, contract, and integration tests will have found any issues LONG before an e2e suite executes. These tests are often very slow and very prone to false negatives because of timeouts.

## Reducing cost
Think of every kind of test you might write in terms of expense. If they take a long time to execute and are brittle they are more expensive. If they execute very quickly and consistently then they are cheap. As much as you possibly can, push towards the cheapest tests you can write. I've released very large projects that are backed entirely by sociable unit tests and I had extreme confidence in them. I've also seen teams bogged down with hours of end-to-end tests that failed half the time. It's not a great place to be in. 

The cheaper your tests are, the more you can run them. Your e2e suite might take 20 minutes and only be run when you're about to release, but your unit testing suite will likely be run constantly while developing and as part of CI pipeline. Given that the whole point is fast feedback for developers you want to be executing your tests as frequently as possible.

[The next article](https://www.aprincipalengineer.com/blog/automated-testing-false-negative-rate/index.html) will cover false negative rates and how to lower them.