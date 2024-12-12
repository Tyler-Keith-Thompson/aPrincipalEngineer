//
//  Index.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/1/24.
//

import Elementary

public struct Index: HTML, Sendable {
    let posts: [BlogPost]
    public init(posts: [BlogPost]) {
        self.posts = posts
    }
    
    public var content: some HTML {
        DefaultContent(title: "Home") {
            cite {
                "A Principal Engineer was created to give tips and advice to those seeking to grow as Software Engineers. As I look back on my career and reflect on how I have suceeded (and failed!) I decided it's time to share that with anybody who is interested. The blog is full of opinions and experiences very much colored by my life, but it's all stuff I wish I could've told myself starting out."
            }
            hr()
            div(.class("grid")) {
                hgroup {
                    h3 {
                        "Opinion Warning!"
                    }
                    p {
                        "This blog covers a host of topics that are difficult to objectively measure. You'll find it very opinion heavy, but those opinions are formed from lots of experience."
                    }
                }
                hgroup {
                    h3 {
                        "Employee Oriented."
                    }
                    p {
                        "There are plenty of blogs catered to businesses. What you'll find here is for employees. If you want to become a senior technical leader then this is the place for you!"
                    }
                }
                hgroup {
                    h3 {
                        "Engineering."
                    }
                    p {
                        "You'll find lots of engineering content. This all comes from personal experience on large and small teams across multiple companies."
                    }
                }
                hgroup {
                    h3 {
                        "Swift."
                    }
                    p {
                        "We love Apple development and the Swift programming language! Expect to see full-stack style swift posts, this isn't just about iOS, this is about an entire ecosystem of which iOS is one part."
                    }
                }
            }
            hr()
            h4(.style("text-align: center;")) { "My latest posts and rants." }
            ForEach(posts) { post in
                BlogHeader(blog: post)
                p { post.description }
                hr()
            }
        }
    }
}
