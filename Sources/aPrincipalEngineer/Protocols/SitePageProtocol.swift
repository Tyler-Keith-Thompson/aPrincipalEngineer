//
//  SitePageProtocol.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot
import Publish

protocol SitePageProtocol {
    var html: HTML { get }
    var path: Path { get }
}

extension SitePageProtocol {
    var path: Path {
        Path(String(describing: Self.self).lowercased() + ".html")
    }
}

extension Item: SitePageProtocol {
    var html: HTML { HTML() }
}

extension Section: SitePageProtocol {
    var html: HTML { HTML() }
}

extension Page: SitePageProtocol {
    var html: HTML { HTML() }
}

extension TagListPage: SitePageProtocol {
    var html: HTML { HTML() }
}

extension TagDetailsPage: SitePageProtocol {
    var html: HTML { HTML() }
}
