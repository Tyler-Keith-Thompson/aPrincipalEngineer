---
date: 2022-07-21 22:00
description: Tests that are closer to production code are easier to execute. Let's dive into details about how to keep your tests close to your production code.
tags: engineering, testing
author: Tyler Thompson
title: Automated Testing: Proximity to Production Code
---

## The proximity to code principle
**Proximity to code**: Given the choice between 2 test harnesses that prove the same thing, one executing locally and one executing in the cloud, use the local test suite. Having tests live in close proximity to code encourages tests to be frequently run, it can mean that your tests can execute without internet access, and it means that they're convenient to sanity check commits and other small units of work in real time.

## Keep tests in the same repo as production code
I've often seen teams choose to move tests that are slow or brittle to a different repository with a different pipeline. This is inevitably a bad solution because the tests will certainly be ignored. Instead, refer to [the cost principle](https://www.aprincipalengineer.com/blog/automated-testing-cost/index.html) and move those tests to a suite that isn't as slow or brittle.

In many ways it'd be better to outright delete tests than it would be to move them to a different repo. If tests are moved to a different repository sometimes tests that are valuable will be added there, but it makes it so inaccessible during standard development those good tests won't be run. It's a similar concept to deleting a flaky feature rather than hiding it behind a feature flag. You don't want to clutter things up just because you invested in it once.

## Tests should be painful when they fail
Remember we focused on [false negative rate](https://www.aprincipalengineer.com/blog/automated-testing-false-negative-rate/index.html) as a metric. If tests have a high false negative rate it'd be better to delete them than it is to skip them or change your pipeline so that test failures don't stop it.

Test failures should be painful, because test failures should be giving you valuable feedback that something doesn't work. When I see teams change their processes so that test failures don't stop progress I see those teams miss important information. I've had many times when I've seen a team comment out a test, or skip it just to find out later that they broke something and that test was pointing them to the issue.

Keep your test failures painful, make them stop releases, prevent merges, and fail pipelines. Focus on false negative rates and remember that it's better to delete a test than it is to ignore it.

## Beware cloud-hosted test harnesses
There are so many services out there that like to boast making testing easy. Many of them use cloud hosting and cloud-based test running. This takes your tests away from your production code and it makes them require an internet connection to run. Neither of those situations is ideal. 

Remember, our tests must have the [ability to catch undesirable change](https://www.aprincipalengineer.com/blog/automated-testing-ability-to-catch-undesirable-change/index.html). That involves frequently running them, ideally every time there is a change. It'll be much harder to run them frequently if they exist in a completely different environment to your production code. 

## Be mindful of testing culture
I am very wary of separate testing teams or QA engineers that don't pair with software engineers. Many of the problems discussed in this article crop up when you've got separate testing and implementation teams. In my entire career I've quite literally never seen this setup work well. Cultural problems inevitably creep up and the test suite suffers for it.

One consequence is a "not my problem" kind of mentality that springs up. If developers that implement a feature are not responsible for testing that feature they also don't take responsibility when tests fail. Additionally, the people that do write automated tests want their own controlled environment and extract tests to a different repository, causing all problems to get worse.

Even with very mature teams I've seen cultural breakdown. For example, people will choose not to write unit tests because somebody else is going to write UI tests. This violates [the cost principle](https://www.aprincipalengineer.com/blog/automated-testing-cost/index.html) and causes the cultural rift and "not my problem" mentality to get worse over time.

To be clear, a QA engineer position can still be valuable, I'm not knocking the role. I'm simply stating that those who write tests need to be very close to those that implement systems. That could mean pairing, or it could mean the same person does all the work. 

As a team member I encourage you to push for unit tests on merge requests, communicate with people who write UI tests and tell them what is already covered, and be the person who doesn't consider code production ready until tests are in place. I think this is a good hill to die on, because untested systems are so much harder to work in. A mature automated testing suite helps everybody, even if it's more work up front.