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

    var formattedName: String { name }

    enum AuthorDecodingError: Error {
        case noAuthorFound(name: String)
    }

    static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
               && lhs.bio.string == rhs.bio.string
    }

    fileprivate init(name: String, bio: Markdown) {
        self.name = name
        self.bio = bio
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let nameLookup = try container.decode(String.self)

        guard let author = Self.allAuthors.first(where: { $0.formattedName.lowercased() == nameLookup.lowercased() }) else {
            throw AuthorDecodingError.noAuthorFound(name: nameLookup)
        }

        self.name = author.name
        self.bio = author.bio
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.bio.string)
    }
}

extension Author {
    static var allAuthors: [Author] {
        [
            .init(name: "Tyler Thompson",
                  bio: Markdown("""
                    Tyler Thompson is a Principal Engineer with over 15 years experience. He currently works as a Principal Software Engineer for Zillow Group. Before working at Zillow he was a Principal Software Engineer for a consulting company and worked across many different industries.
                  """))
        ]
    }
}
