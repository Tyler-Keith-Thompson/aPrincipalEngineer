---
date: 2022-06-06 12:00
description: My impressions on WWDC 2022, the things I found excited, and areas I intend to explore next.
tags: swift, wwdc
author: Tyler Thompson
title: WWDC 2022 Overview
---

## WWDC 2022
Another year, another WWDC. It was honestly great to be able to check out the Keynote today. I had a few people texting me for my opinion and about 6 slack threads open with snarky comments and excited chatter. Now I've got a warning on the whole blog but just to rehash this is entirely based on my opinion. Yours may differ, feel free to leave comments!

### The Sexy
There's so much in this category this year! I honestly went in uncertain about how much innovation we'd see, especially after how dispruptive last year was. I was pleasantly surprised, let's dive in.

- **Live Text**: Did you see this?! I am amazed at how well live text appears to work in iOS 16. This is leaps and bounds for accessibility, for translation, for convenience, for really useful in-app experiences.
- **Zillow Callout**: Okay, I'm a little bit biased (read: very biased) because I work for Zillow, but how cool was it that we got name dropped by Apple this year?
- **SwiftUI Enhancements**: You could be forgiven for missing this because it FLASHED past but NavigationView is finally getting an upgrade. It looks like they're exposing control over the navigation stack. This also deserves honorable mention in "It's about time." I am really looking forward to the next few days where I can learn more.
- **PassKey**: This is great. I want to be clear, Apple doesn't deserve all the credit for WebAuthn, it's a cross-industry effort. That said, the future is here! I absolutely love passwordless authentication. This is going to really help mitigate alot of existing risk. It'll also expose a bunch of new attack vectors, remember, bad actors will always find new ways of getting data.
- **WeatherKit**: I recognize there were already weather services you can use, but seeing Apple integrate it as a very usable service, much like MapKit, is very cool. I can see lots of useful ways to combine it with location-aware apps. 
- **Generics and Existentials**: Ahh, I have really been looking forward to the generics and existential upgrades we're getting. `any Thing` and `some Collection<Thing>` really spoke to me. If you haven't dealt a lot with generics you might be thinking "So what?" But for those who have, this exposes lots of really fun new possibilies. 
- **Regex Builders**: So I love regex, and thus I am somewhat excited for regex literals...but builders are frankly way more sexy. Regex is not *remotely* approachable for people. It's weird to learn, it's terse and archaeic. That said, builders are very approachable and I think we're going to see people build some really powerful parsers using regex builders. MAYBE we will even see people encouraged to stay away from regex when it's not the right tool for the job.
- **Swift Package Plugins**: Look! We almost have a for reals build chain! It's so exciting. I love that this is driven through SPM and I think we'll see some really impressive work done with codegen and Xcode integration now that this is available.
- **Distributed Actors**: I've had my eye on you, distributed actors. So here's the thing, this won't speak to everybody. But if you're a fan of Swift on server (I am!) then you will see potential here. I have also developed a few different enterprise apps where we needed a way to communicate cross-process. Distributed actors could be just the thing!
- **DocC Updates**: Okay, they didn't mention this today, but trust me, it's a thing. DocC supports static site generation, in fact, I just got this working with one of my open source projects recently. I know documentation sucks for developers, but I genuinely think some of the upcoming changes are going to make it suck a lot less.

### The Blasè
- **Xcode Cloud**: This took forever to release. I have been really eager to see it but was really disheartened by the pricing I saw today. I do a lot of open source work, I wanted to see a "free to use for OSS" statement, but didn't get it. 20 hours of build time free is nothing to sneeze at, but then the pricing gets unrealistic for individual developers. Why would you choose this when there are very good CI/CD solutions you can use for free?
- **Lock Screen Updates, Map Updates, General UI things**: Don't get me wrong, I had several "ooh, that looks good" moments when I saw this. Particularly when the map went into dark mode and buildings lit up. However, these updates aren't sexy, they're delightful. As a developer, they are just sort of amusing.
- **New Hardware and M2**: Look this is cool, but I use a desktop. I'll be investing in a Mac Studio soon. It's great you managed to shave off some pounds and make the air EVEN SMALLER but that's not what speaks to me. I'll think this is more exciting when they're announce the M2 Max Ultra Super Duper (their naming convention is getting weird). For portability I use an iPad, it does great.
- **Apple Pay Later**: Once again, I think this is cool as a consumer. As a developer it's not all that exciting because you integrate the exact same way. 
- **Metal Updates**: I think game devs are very impressive, but the thing is Metal isn't approachable for beginners and AAA game companies aren't gonna be interested before C++ interop is a thing. They're headed in the right direction, but I don't predict we'll suddenly see major releases targetting macOS as a priority.
- **The Rest**: Yeah, I know there's a lot more I didn't mention. That's because it didn't make a strong impression on me as an engineer. I think there's some cool things if you're a consumer of Apple products, my wife will be really happy about some of the new iPad things, but nothing else changes the way I code or much of my personal workflow.

### The "It's About Time"
- **iMessage Editing**: Seriously Apple?! It took you to 2022 to do this? I mean I'm glad it exists but I can't help but wonder if the insistence on your own protocol and own messaging system caused these issues. You could've used a standard and had this available much earlier.
- **SwiftUI NavigationView Updates**: Okay, I added this in "The Sexy" category, because I've been wanting it for a long time. That said, navigation has been laughably bad for complex workflows in SwiftUI since day one, so "it's about time".

### The Missing
- **RealityOS**: We all know it's coming, frankly I'm glad they're taking their time. I, and many others, believe that Apple glasses will eventually be announced. I want them to take their time and get it right, we don't need a repeat of Google Glass.
- **Other SwiftUI Navigation Patterns**: So...nav stacks *might* be more sane now, but what about modals? What about other forms of presentation? I want control over the stack!
- **Variadic Generics**: There's been multiple proposals here, but I really hope this is coming soon. This would solve a lot of weirdness for result builders and arity issues. To put that in english, your SwiftUI views could have more than 10 things without having to use a group.
- **Reflection**: Am I the only one who thinks Swift needs for reals reflection? Better reflection would allow us new dependency injection frameworks and actual mocking frameworks. It's a little baffling to me this is never on the radar.
- **Xcode for iPad**: WHY APPLE?! Why won't you just do it? The iPad is running on M1, this seems feasible. Or at least make Swift Playgrounds a better dev environment. I was really hoping this'd be announced this year.