//
//  Header.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot
import Publish

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
                .stylesheet("https://cdn.jsdelivr.net/npm/@algolia/algoliasearch-netlify-frontend@1/dist/algoliasearchNetlify.css"),
                .viewport(.accordingToDevice),
                .unwrap(context.site.favicon, { .favicon($0) }),
                .link(.rel(.appleTouchIcon), .href("apple-touch-icon.png")),
                .link(.rel(.shortcutIcon), .href("favicon.ico")),
                .script(.src("js/modernizr.js")),
                .script(.src("https://cdn.jsdelivr.net/npm/@algolia/algoliasearch-netlify-frontend@1/dist/algoliasearchNetlify.js")),
                .script(.raw(#"""
                  algoliasearchNetlify({
                    appId: '8NTJ9FBH6D',
                    apiKey: '3710476d73f618f3e5e17e7045d987a9',
                    siteId: '644efd51-7b54-49ee-85ea-35078be936cf',
                    branch: 'main',
                    selector: 'div#search',
                  });
                """#)),
                .raw(#"""
                <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-6671003298911092"
                     crossorigin="anonymous"></script>
                """#)
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
