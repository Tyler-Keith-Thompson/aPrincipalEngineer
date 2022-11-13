---
date: 2022-07-20 11:30
description: The ability to catch undesirable change is the crux of automated testing, let's dive into the details of how we should create tests that catch undesirable change.
tags: engineering, testing
author: Tyler Thompson
title: Automated Testing: Ability to Catch Undesirable Change
---

## The undesirable change principle
**Ability to catch undesirable change**: This is one of the primary purposes of a test harness. Undesirable change usually means bugs. Automated tests report on change in a codebase. Make sure reported changes are undesirable. 

## Coverage is not a good primary metric
In teams where you use measurements to encourage good practices it can be common for people to set team goals to have high coverage numbers. What is coverage? Many test runners can measure which parts of production code are exercised by tests. When all tests are finished it can show how much production code is "covered", and which parts are not covered. Coverage is a useful metric but it doesn't tell you that tests will catch undesirable change, it only tells you that tests exercise production code.

In [the last article](https://www.aprincipalengineer.com/blog/automated-testing-false-positive-rate/index.html) we talked about mutation testing and a mutation score. If you combine a mutation score with coverage this can be a *better* metric. It'll tell you that not only is something covered, but that it catches logical errors.

## Write your tests early in your development cycle
This is a great time to talk about TDD (Test Driven Development) as a practice. TDD involves writing a test before you write any production code. This practice has a host of benefits, for one you get naturally high test coverage, this method also encourages architectures that are testable. If we lived in a perfect world, it'd be worthwhile using TDD to develop everything.

TDD isn't always possible, it's a skill that takes a long time to master and developers may not have that skill or have the desire to hone it. Even for those who use TDD regularly there are times when there are too many unknowns to write a test first. In these cases, there's a different solution.

## Ensure tests fail, before they pass
Whether you use TDD or not it's crucial to make sure you've witnessed a test failing for the right reason, ideally before you see it passing for the right reason. If your test is written first this is as simple as running it. If your production code is written first, comment out that production code, then run your test, it should fail. Uncomment the production code and run your test again, it should pass.

By witnessing tests fail you gain confidence they assert desired behavior. Tests that assert on desirable behavior will catch when that desirable behavior isn't working. In other words, those tests will likely catch undesirable change.

## Write lots of tests
Each test you write should target some small piece of behavior. Make sure you keep writing tests until those tests observe all behavior that's important to you. By continuing to write tests until they observe all important behavior you'll catch undesirable changes better. Remember that automated tests aren't there to make your code bug-free, but they should drastically reduce the severity/likelihood of bugs making it to production.

## Name your tests wisely
When tests fail the name of the failing test is shown, as well as what assertions failed. These test names should give you a very good idea of what has gone wrong. `testFoo` doesn't help anybody, but `testWhenEnteringAValidUsernameAndPassword_TheUserIsLoggedIn` describes very adequately what the test should be proving.

## Run your tests regularly
We [focused so heavily on cost](https://www.aprincipalengineer.com/blog/automated-testing-cost/index.html) first for this moment. Tests catch changes when they're run, you should make sure they're run frequently so that you get feedback early. It's also important to run tests as a natural, and largely unavoidable part of your process. CI/CD pipelines are perfect for this, every time somebody commits to your codebase you can run your tests. Because commits represent changes, this is a naturally perfect time to run your tests.

Tests running on a cadence can sometimes be valuable but beware of this, if you've got a separate pipeline that runs tests every week it's much easier to ignore than tests that run on every change. This has to do with where pain is felt. Running tests on commits means that you can prevent those commits from being merged and part of production code. However, when running on a cadence it's unlikely you'll have the same processes in place to prevent those changes from going live.

The times when I've run tests on a cadence are times when I'm writing tests for systems I don't control. For example, integration tests on an external service. It's difficult to design these tests so that they give valuable feedback. Sometimes an external service fails the test for the wrong reasons, the more this happens, the more likely it is the suite will be ignored.

In [the next article](https://www.aprincipalengineer.com/blog/automated-testing-ability-to-support-desirable-change/index.html) we'll cover supporting desirable change.