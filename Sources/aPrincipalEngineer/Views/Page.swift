//
//  Header.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot
import Publish

@available(macOS 10.12, *)
struct SitePage {
    let sitePage: SitePageProtocol
    let context: PublishingContext<APrincipalEngineer>

    @ComponentBuilder public var content: () -> ComponentGroup

    public var html: HTML {
        HTML(
            .lang(context.site.language),
            .raw(#"<!--[if lt IE 8 ]><html class="no-js ie ie7" lang="en"> <![endif]-->"#),
            .raw(#"<!--[if IE 8 ]><html class="no-js ie ie8" lang="en"> <![endif]-->"#),
            .raw(#"<!--[if (gte IE 8)|!(IE)]><!--><html class="no-js" lang="en"> <!--<![endif]-->"#),
            .head(
                .encoding(.utf8),
                .siteName(context.site.name),
                .url(context.site.url(for: sitePage.path)),
                .title(context.site.name),
                .description(context.site.description),
                .forEach(["css/default.css", "css/layout.css", "css/media-queries.css"], { .stylesheet(context.site.url.appendingPathComponent($0)) }),
                .viewport(.accordingToDevice),
                .unwrap(context.site.favicon, { .favicon($0) }),
                .link(.rel(.appleTouchIcon), .href("apple-touch-icon.png")),
                .link(.rel(.shortcutIcon), .href("favicon.ico")),
                .script(.src("js/modernizr.js"))
            ),
            .body {
                SiteNavigation(context: context, page: sitePage)
                content()
                SiteFooter(context: context)
            }
        )
    }

    var pathModifier: String {
        (sitePage.path.absoluteString.dropFirst().components(separatedBy: "/").map { _ in "" } + (sitePage.path.absoluteString.hasSuffix(".html") ? [] : [""])).joined(separator: "../")
    }
}
