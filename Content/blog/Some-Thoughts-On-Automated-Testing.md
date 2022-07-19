---
date: 2022-07-17 15:30
description: My thoughts and opinions on the value of automated testing.
tags: engineering, testing
author: Tyler Thompson
title: Some Thoughts on Automated Testing
---

## Motivation
I've been practicing TDD (Test Driven Development) for many years now. I don't consider code to be production ready unless it's got some kind of test backing it up. Tests make their way into my side projects, utilities, and even this blog. This article series will delve into details about what, in my opinion, constitutes a good test harness and where you should invest time in automated testing.

## Why write tests?
Tests make their way into everything I do because they give me confidence. With a robust automated testing harness I can release on demand, I can refactor without fear of breaking critical functionality, and I can greatly increase my productivity as projects age. An added benefit is that my testing suite provides documentation for expected behavior of whatever I'm building. I can go back years later and understand exactly what I was trying to do.

## When are tests not valuable?
Automated testing is great for repeatable processes, but really bad at judgement. You'll always want human eyes to guage whether your user experience is good. Automated tests also primarily catch change, this means if something changes frequently tests can become noisy and unhelpful. To that end, I don't test things like colors, fonts, padding, etc..because those things can change very frequently. My tests are entirely focused on expected behavior, things that won't change frequently.

## How do you measure the value of tests?
First, to be clear, even with a mature and robust automated testing suite bugs will get out into production. You know your test harness is useful if the severity/liklihood of bugs found in production is favorable. In other words, an automated testing suite may not catch a critical severity bug that has a very low chance of happening. Or it might not test a very minor but prolific bug. That's acceptable, but a good automated test harness will make sure that the things you care about continue to work. Here's how I measure the value of an automated testing suite.

#### You can measure your automated tests by:
- **[Cost](https://www.aprincipalengineer.com/blog/automated-testing-cost/index.html)**: This is often measured in time. If two tests harnesses prove the same thing, but one executes in a few seconds and the other in a few minutes, I'll always prefer the one that executes faster. Fast tests give developers immediate feedback and are more likely to be run repeatedly.
- **False negative rate**: Tests that fail for the wrong reasons are disasterous. The more this happens the more likely teams are to ignore their tests. An ignored test suite is not providing value. Therefore, a test harness with a lower false negative rate is preferable.
- **False positive rate**: Tests with a high false positive rate don't cause immediate pain, they cause pain later on. This undermines confidence in all tests and can ruin efforts to get automated tests in place. Therefore, a test harness with a lower false positive rate is preferable.
- **Ability to catch undesirable change**: This is one of the primary purposes of a test harness. Undesirable change usually means bugs. Automated tests report on change in a codebase. You want to make sure that the change that's reported is undesirable. 
- **Ability to support desirable change**: This primarily means the ability to refactor. A good automated testing suite isn't coupled to implementation details, and is instead focused on desired behavior. This means that if you want to change to a new architecture or completely refactor your codebase it's preferable that your test harness supports that change.
- **Proximity to code**: Given the choice between 2 test harnesses that prove the same thing, one executing locally and one executing in the cloud, I'll take the local test suite. Having tests live in close proximity to code encourages tests to be frequently run, it can mean that your tests can execute without internet access, and it means that they're convenient to sanity check commits and other small units of work in real time.

In [the next article](https://www.aprincipalengineer.com/blog/automated-testing-cost/index.html) we'll dive into each of these concepts one-by-one and talk about how to maximize and measure each one. For now, be that voice on your team to push for automated testing, don't let tests become an afterthought. You'll find that writing tests encourages better architectural decisions, allows for better release processes, and despite an initial investment, greatly speeds up development.