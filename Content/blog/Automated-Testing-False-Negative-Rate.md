---
date: 2022-07-19 11:45
description: Learn how to minimize false negative rates writing automated tests. Learn about the different processes and tools that can help with a low false negative rates.
tags: engineering, testing
author: Tyler Thompson
title: Automated Testing: False Negative Rate
---

## The false negative principle
**False negative rate**: Tests that fail for the wrong reasons are disastrous. The more this happens the more likely teams are to ignore their tests. An ignored test suite is not providing value. Therefore, a test harness with a lower false negative rate is preferable.

## What causes false negatives?
False negatives are often caused by sources external to your system. For example, an integration test might fail because of network latency, an e2e or slow UI test might fail because of an animation. There's also issues with shared testing environments. If one test tries to read a resource and another tries to delete it, you might end up with with a race condition that causes a false negative.

Lastly, the wrong assertion can easily create false negatives. One advantage to writing tests before you write production code to satisfy those tests, is that your assertions tend to be better. If you find yourself writing assertions based on implementation details you could be creating conditions for a false negative after a refactor. Assertions should be all about consumer expectations. If you have a button on a screen that triggers a network request, and on completion shows a confirmation screen, arrange your test by stubbing the network response, then tap the button, then assert the correct network request was sent and that the confirmation view was shown. Those assertions are about user expectations, they are the most important details about this hypothetical flow.

## How to stop false negatives?
Start by eliminating external dependencies as much as you reasonably can. Did you need an integration test or can it be a contract test? Do you need to actually send a request of HTTP or can you stub your network layer? Then eliminate causes of delays. For example, disable animations when running your tests. Finally, avoid sleeping for a set duration like the plague. If your test must wait, wait on a specific condition, like a network call completing, or a view rendering, or a control becoming enabled. It's okay to wait with a timeout, but adding `sleep` to your automated test is a surefire way to cause false negatives and brittle tests.

I also suggest avoiding prototypical UI testing frameworks. Appium, XCUITest, selenium, and others like them are incredibly slow frameworks. While they can provide value in an e2e suite, you're better off using a faster and more reliable framework. For example, using [ViewInspector](https://github.com/nalexn/ViewInspector) to test SwiftUI, or [UIUTest](https://github.com/nallick/UIUTest) to test UIKit. Both of these are unit testing frameworks, but they give a lot of the same value that UI testing frameworks give. For example, they perform hit testing, they can throw an error if you try and tap on a disabled button, and more. They're also much more consistent and reliable.

In [the next article](https://www.aprincipalengineer.com/blog/automated-testing-false-positive-rate/index.html) we'll go over details on false positive rates and how to lower them.