//
//  Author.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Publish
import Foundation

@available(macOS 12.0, *)
struct Author: WebsiteItemMetadata {
    let name: PersonNameComponents
    let bio: Markdown

    enum AuthorDecodingError: Error {
        case noAuthorFound(name: String)
    }

    static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
               && lhs.bio.string == rhs.bio.string
    }

    fileprivate init(name: PersonNameComponents, bio: Markdown) {
        self.name = name
        self.bio = bio
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let nameLookup = try container.decode(String.self)

        guard let author = Self.allAuthors.first(where: { $0.name.formatted().lowercased() == nameLookup.lowercased() }) else {
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

@available(macOS 12.0, *)
extension Author {
    static var allAuthors: [Author] {
        [
            .init(name: PersonNameComponents(namePrefix: nil, givenName: "Tyler", middleName: "Keith", familyName: "Thompson", nameSuffix: nil, nickname: nil, phoneticRepresentation: nil),
                  bio: Markdown("""
                    Tyler Thompson is a Principal Engineer with over 15 years experience. He currently works as a Principal Software Engineer for Zillow Group. Before working at Zillow he was a Principal Software Engineer for a consulting company and worked across many different industries.
                  """))
        ]
    }
}
