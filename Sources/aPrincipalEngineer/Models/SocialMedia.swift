//
//  SocialMedia.swift
//  
//
//  Created by Annalise Mariottini on 5/5/24.
//

import Foundation

struct SocialMedia: Hashable {
    let site: Site
    let title: String
    let url: String

    static func gitHub(_ title: String, url: String) -> Self {
        .init(site: .gitHub, title: title, url: url)
    }

    static func linkedIn(_ title: String, url: String) -> Self {
        .init(site: .linkedIn, title: title, url: url)
    }
}

extension SocialMedia {
    enum Site: String {
        case gitHub = "GitHub"
        case linkedIn = "LinkedIn"
    }
}
