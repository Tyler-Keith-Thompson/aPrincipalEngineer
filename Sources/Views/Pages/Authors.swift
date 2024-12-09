//
//  About.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/9/24.
//

import Elementary

public struct Authors: HTML, Sendable {
    public init() { }
    
    public var content: some HTML {
        DefaultContent(title: "About") {
            cite {
                "A Principal Engineer was created to give tips and advice to those seeking to grow as Software Engineers. As I look back on my career and reflect on how I have suceeded (and failed!) I decided it's time to share that with anybody who is interested. The blog is full of opinions and experiences very much colored by my life, but it's all stuff I wish I could've told myself starting out."
            }
            hr()
            div(.class("row-fluid")) {
                div(.class("col-2")) {
                    img(.src("/images/tyler-min.png"), .class("profile-picture"))
                }
                div(.class("col-10")) {
                    h4 { "About the author" }
                    span { "Tyler Thompson is a Principal Engineer with over 17 years experience. He currently works as a Senior Software Engineering Manager for Zillow Group. Before working at Zillow he was a Principal Software Engineer for World Wide Technology and worked across many different industries." }
                }
            }
        }
    }
}
