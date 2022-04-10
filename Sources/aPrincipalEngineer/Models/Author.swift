//
//  Author.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Publish
import Foundation

@available(macOS 10.12, *)
struct Author: WebsiteItemMetadata {
    let name: PersonNameComponents
    let bio: Markdown

    var formattedName: String {
        let formatter = PersonNameComponentsFormatter()
        return formatter.string(from: name)
    }

    enum AuthorDecodingError: Error {
        case noAuthorFound(name: String)
    }

    static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
               && lhs.bio.string == rhs.bio.string
    }

    fileprivate init(name: String, bio: Markdown) {
        let formatter = PersonNameComponentsFormatter()
        self.name = formatter.personNameComponents(from: name)!
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

@available(macOS 10.12, *)
extension Author {
    static var allAuthors: [Author] {
        [
            .init(name: "Tyler Keith Thompson",
                  bio: Markdown("""
                    Tyler Thompson is a Principal Engineer with over 15 years experience. He currently works as a Principal Software Engineer for Zillow Group. Before working at Zillow he was a Principal Software Engineer for a consulting company and worked across many different industries.
                  """))
        ]
    }
}
