//
//  File.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot

protocol SitePage {
    var html: HTML { get }
    var path: String { get }
}

extension SitePage {
    var path: String {
        String(describing: Self.self).lowercased() + ".html"
    }

    var navigation: Component {
        SiteNavigation(for: self)
    }
}
