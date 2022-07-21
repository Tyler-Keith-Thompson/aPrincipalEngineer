---
date: 2022-07-20 1:30
description: Learn how to minimize false positive rates writing automated tests. Learn about the different processes and tools that can help with a low false positive rates.
tags: engineering, testing
author: Tyler Thompson
title: Automated Testing: False Positive Rate
---

## The false positive principle
**False positive rate**: Tests with a high false positive rate don't cause immediate pain, they cause pain later on. This undermines confidence in all tests and can ruin efforts to get automated tests in place. Therefore, a test harness with a lower false positive rate is preferable.

## Feel pain as soon as possible
If pain is going to be felt, it is best that pain is felt early. Reflect on this statement because it applies to virtually every aspect of software development and beyond. In a lot of ways this is why we even write tests to begin with. If there's some kind of undesirable behavior we want to know about it right away so that we can fix it. This also touches on concepts like crash-first development, which we'll go over is some later post.

One of the reasons we focus on cheap tests is so that we can frequently run them. Ideally all tests are run with every change, if your test harness is lightweight this is totally achievable and gives extreme confidence. This means after making a change locally you can run tests, it also means your CI pipeline can and should run tests. It should also deliberately fail if tests do not pass. These are ideal setups and it's worth putting a lot of effort into creating.

## What causes false positives?
False positives always have the same cause, some part of your test is incorrect. It could be that when you setup preconditions for your tests, those preconditions weren't valid. It could be that when your test acts it's not acting like a user really would, and thus isn't giving the right feedback. The most frequent I see is that assertions are the wrong assertions. Your assertions might be asserting on something irrelevant or they might not actually be happening at all.

Let's talk about those assertions. When your test asserts something, you want to make sure it's asserting expected behavior. When I see tests written by those who are unfamiliar with automated testing I almost always see some flavor of `assertNotNull(thingThatCannotBeNullAnyways)`. I'll also sometimes see a test set up an expectation but then fulfill that expectation without exercising production code. These will increase your coverage numbers, but are a waste of computing resources.

## How can we detect false positives?
It's a little expensive in terms of compute power but [Mutation Testing](https://en.wikipedia.org/wiki/Mutation_testing) is a great way of detecting false positives. The short version is that mutation testing will create "mutants" in your production code, it might change `>` to `<` or `==` to `!=`. It'll then run your tests, the code should either refuse to compile or the tests should fail. If the production code is mutated and tests do not fail, that mutant will be reported and it'll hurt your mutation score. Ideally, you want your tests to catch all mutants as they represent undesirable behavior.

I love mutation testing as a sanity check but because it's having to recompile code frequently it takes a very long time to run. Because mutation tests are a sanity check I don't recommend running them as frequently. I've set them up to on a cadence for projects under active development. These tests will go a long ways towards identifying false positives and giving you more confidence in your test suite.

In [the next article](https://www.aprincipalengineer.com/blog/automated-testing-ability-to-catch-undesirable-change/index.html) we'll talk about catching undesirable change, mutation testing can be a very valuable tool to check that your tests catch undesirable change.