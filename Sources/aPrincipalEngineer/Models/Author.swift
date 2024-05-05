//
//  Author.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Publish
import Foundation

struct Author: WebsiteItemMetadata {
    let name: String
    let bio: Markdown
    let socialMedia: [SocialMedia]

    var formattedName: String { name }

    var image: String {
        "\(name.lowercased().components(separatedBy: " ").joined(separator: "-")).png"
    }

    enum AuthorDecodingError: Error {
        case noAuthorFound(name: String)
    }

    static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
               && lhs.bio.string == rhs.bio.string
    }

    fileprivate init(name: String, bio: Markdown, socialMedia: [SocialMedia]) {
        self.name = name
        self.bio = bio
        self.socialMedia = socialMedia
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let nameLookup = try container.decode(String.self)

        guard let author = Self.allAuthors.first(where: { $0.formattedName.lowercased() == nameLookup.lowercased() }) else {
            throw AuthorDecodingError.noAuthorFound(name: nameLookup)
        }

        self.name = author.name
        self.bio = author.bio
        self.socialMedia = author.socialMedia
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.bio.string)
        hasher.combine(self.socialMedia)
    }
}

extension Author {
    static var allAuthors: [Author] {
        [
            .tylerThompson,
            .annaliseMariottini
        ]
    }

    static var tylerThompson: Author {
        .init(name: "Tyler Thompson",
              bio: Markdown("""
                Tyler Thompson is a Principal Engineer with over 15 years experience. He currently works as a Principal Software Development Engineer for Zillow Group. Before working at Zillow he was a Principal Software Engineer for World Wide Technology and worked across many different industries.
              """),
              socialMedia: [
                .linkedIn("Tyler K. Thompson", url: "https://www.linkedin.com/in/tyler-k-thompson/"),
                .gitHub("Tyler-Keith-Thompson", url: "https://github.com/tyler-Keith-Thompson"),
              ])
    }

    static var annaliseMariottini: Author {
        .init(name: "Annalise Mariottini",
              bio: Markdown("""
                Annalise Mariottini is a software engineer, currently working on the Mobile App Platform team at Zillow Group, alongside Tyler Thompson and many other bright engineers. She has a passion for creating human-first engineering tools and technologies. She earned a B.A. in C.S. and Visual Arts from Columbia University.
                """),
              socialMedia: [
                .linkedIn("Annalise Mariottini", url: "https://www.linkedin.com/in/amariottini/"),
                .gitHub("aim2120", url: "https://github.com/aim2120"),
              ])
    }
}
