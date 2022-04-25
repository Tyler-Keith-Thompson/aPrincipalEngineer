---
date: 2022-04-24 20:30
description: Learn about how "A Principal Engineer" was created using Swift!
tags: engineering, swift
author: Tyler Thompson
title: Making this blog
---

## Motivation
Now that I've been a Principal Engineer for a few years, I think it's time to try and share some details about how I got where I am. My hope is that others trying to become technical leaders can benefit from some of my lessons learned along the way. So I decided to make a blog. It seems to me that a "making of" post is as good a place to start as any.

## Creating the blog code
My favorite programming language is Swift. Many people believe it's just for iOS development, but that is untrue. Swift is a fantastic multi-paradigm language that you can use to build virtually anything. If I had to describe myself as an engineer, I would probably say I'm a full-stack Swift developer.

John Sundell wrote [Publish](https://github.com/johnsundell/publish), which is an excellent static site generator for Swift. I previously used Publish to write my resume, so it was a natural choice when making the blog. It makes excellent use of Swift's generic system and result builders to create HTML. 

I'm not a designer, so I needed a template. I found a wonderful free-to-use template called "Sparrow 1.0" and was well on my way. I have got to give the designers huge credit because it's one of the best templates I have ever used. The HTML came formatted, and the CSS was actually understandable. It was even written in such a way that it would not conflict with other CSS you already have. I did notice that it was only a "light mode" type template. I added several CSS media queries to support dark mode based on system settings and contributed that code back to the creators of "Sparrow 1.0".

## Publishing the site
Publishing platforms were a little tricky. I wanted something free, or at least very cheap. I explored using GitHub pages and carefully read the terms. While I didn't see anything that indicated I couldn't use GitHub pages, it felt like a blog would go against the spirit of the feature. Instead, I found [Netlify](https://netlify.com/), which is perfect for hosting static websites. 

## CI/CD pipeline
I am a big believer in automation. Netlify does offer an option to just upload a folder and host it, but I simply cannot pass up the opportunity to push to the `main` branch and have my website deployed a few minutes later. Because Publish is pure Swift, it can run on Linux, which means I could use a swift docker container to generate my static site. I used GitHub actions as a CI/CD provider and a [netlify deploy plugin](https://github.com/jsmrcaga/action-netlify-deploy) to publish the site.

## Pagination
The last big hurdle was getting pagination working reasonably well with a static website. I took a look at some implementations of pagination in other static website generators, like Jekyll. Ultimately, I wrote a build plugin for Publish that did the trick. Here's a taste of the code that backs it.

```swift
extension Plugin where Site == APrincipalEngineer {
    static var generatePaginatedBlogPages: Self {
        Plugin(name: "Generated Paginated Blog Pages") { context in
            guard let blogSection = context.sections.first(where: { $0.id.rawValue == APrincipalEngineer.SectionID.blog.rawValue }) else {
                throw PublishingError(
                    infoMessage: "Unable to find blog section"
                )
            }
            let PAGE_SIZE = 10
            let allItems = context.sections.flatMap { $0.items }
            let pages = (0..<allItems.count / PAGE_SIZE).map { i -> Page in
                let index = i + 1
                let blog = Blog(context: context, section: blogSection, pageSize: PAGE_SIZE, offset: PAGE_SIZE * i)
                return Page(path: Path("pages/\(index)"), content: .init(title: "Blog - Page \(index)", description: "A Principal Engineer Blog - Page \(index)", body: .init(html: blog.html.render()), date: Date(), lastModified: Date(), imagePath: nil, audio: nil, video: nil))
            }

            pages.forEach {
                context.addPage($0)
            }
        }
    }
}
```