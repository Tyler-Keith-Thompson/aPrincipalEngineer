---
date: 2022-07-21 1:30
description: <ADD DESCRIPTION>
tags: engineering, testing
author: Tyler Thompson
title: Automated Testing: Ability to Support Desirable Change
---

## The desirable change principle
**Ability to support desirable change**: A good automated testing suite isn't coupled to implementation details, and is instead focused on desired behavior. This means that if you want to change to a new architecture or completely refactor your codebase, your test harness supports that change.

## From interaction to expected result
In [a previous article](https://www.aprincipalengineer.com/blog/automated-testing-cost/index.html) I talked about Sociable unit testing. This style of testing will serve us well for the conversation on supporting desirable change. An example of desirable change would be a refactor, it's the same observable behavior, but perhaps with code that's more readable, or less code.

The kinds of tests that support desirable change the most tend to be tests that act like a consumer, and assert on end results. For example, in a mobile app that means interacting with the UI like a user, and asserting that some observable behavior happens. This doesn't necessarily mean using a UI testing framework and it definitely doesn't mean starting every test from app launch. It can mean calling the function that triggers on button press, or it could mean using a view testing framework to tap a button.

When it comes to expected results, keep these observable. I had a conversation recently about a unit test we were writing to ensure a list of times was sorted. My colleague suggested that we could just inspect an array and assert the array was sorted. I suggested that we should inspect the view and assert the displayed views were sorted. If we tested the array we were relying on an implementation detail and something as simple as renaming the array breaks the test. There's also a false positive potential because there was no test proving the array is what backed the view.

## Structure of tests
Let's break down "Arrange, Act, Assert" or "Given, When, Then." These are both methods of structuring your tests. They refer to the same concept, you start a test by setting up preconditions. For example, logging in a user, or stubbing out a network layer. You then perform actions, for example tapping a login button. Finally, you assert. To continue the example, you'd assert that a user is logged in, and likely assert that they landed on a home screen.

Using these methods can be a great way to know where to stop one test and start another. In general, you should keep tests to one group of "Arrange, Act, Assert." There will always be exceptions but it's a good rule of thumb.

It's okay for tests to not be DRY. For those unfamiliar DRY stands for "Don't Repeat Yourself" and is a good practice when writing production code. It encourages sharing similar code. However, when writing tests this can cause problems. I might say to have your tests be damp, don't share setup based on data, or configuration. If your tests share too much setup code, they might prove brittle whenever preconditions for one test change.

You should also strive to design your tests to be completely independent. If one test depends on another happening first, you're creating a test suiet that will be hard to maintain. If you really want to drive this home most test runners allow for randomized execution order. 

## Don't test configuration
We build configuration into systems because it might change frequently. For example, you might configure URLs to use for network calls, colors, fonts, and localized strings. Testing this configuration usually doesn't provide valuable feedback and the effort is normally quite large.

Instead, test where configuration is *consumed* and assert that it's consumed correctly. For example, in the case of localized strings you can supply your own test value and assert it's displayed when a view renders. This gives the flexibility that was desired with configuration but confidence that the configuration will be used correctly.

## Don't test design details
Much like configuration design details are rarely worth testing. For example, testing padding on a view is generally a waste of a test. The padding could change and the test would report a failure, but that failure doesn't necessarily give valuable feedback. Designs change frequently, and colors, padding, styling, fonts, and other details are more about delight than functionality. 

Do test important functionality as it relates to design. For example, do test that details from a user's profile are displayed. It shouldn't matter to your automated tests *where* they are displayed, just that the information is on the screen somewhere.