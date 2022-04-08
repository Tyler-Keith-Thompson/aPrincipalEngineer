//
//  Index.swift
//  
//
//  Created by Tyler Thompson on 1/3/22.
//

import Publish
import Plot

struct IndexHTML: SitePage {
    let index: Index
    let context: PublishingContext<APrincipalEngineer>
    init(index: Index, context: PublishingContext<APrincipalEngineer>) {
        self.index = index
        self.context = context
    }

    var html: HTML {
        HTML(
            .lang(context.site.language),
            .raw(#"<!--[if lt IE 8 ]><html class="no-js ie ie7" lang="en"> <![endif]-->"#),
            .raw(#"<!--[if IE 8 ]><html class="no-js ie ie8" lang="en"> <![endif]-->"#),
            .raw(#"<!--[if (gte IE 8)|!(IE)]><!--><html class="no-js" lang="en"> <!--<![endif]-->"#),
            .head(
                .encoding(.utf8),
                .siteName(context.site.name),
                .url(context.site.url(for: index)),
                .title(context.site.name),
                .description(context.site.description),
                .forEach(["css/default.css", "css/layout.css", "css/media-queries.css"], { .stylesheet($0) }),
                .viewport(.accordingToDevice),
                .unwrap(context.site.favicon, { .favicon($0) }),
                .link(.rel(.appleTouchIcon), .href("apple-touch-icon.png")),
                .link(.rel(.shortcutIcon), .href("favicon.ico")),
                .script(.src("js/modernizr.js"))
            ),
            .body {
                navigation
                SiteIntro()
                Element(name: "section") {
                    Div {
                        Div {
                            Div {
                                H2("Clean & Modern.")
                                Paragraph("Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.")
                            }.class("columns")
                            Div {
                                H2("Responsive.")
                                Paragraph("Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.")
                            }.class("columns")
                            Div {
                                H2("HTML5 + CSS3.")
                                Paragraph("Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.")
                            }.class("columns s-first")
                            Div {
                                H2("Free of Charge.")
                                Paragraph("Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.")
                            }.class("columns s-first")
                        }.class("bgrid-quarters s-bgrid-halves")
                    }.class("row")
                }.id("info")
                BlogHighlights(items: Array(context.allItems(sortedBy: \.date, order: .descending).prefix(5)))
                ComponentGroup(html: """
                           <!-- Works Section
                           ================================================== -->
                           <section id="works">

                              <div class="row">

                                 <div class="twelve columns align-center">
                                    <h1>Some of our recent works.</h1>
                                 </div>

                                 <div id="portfolio-wrapper" class="bgrid-quarters s-bgrid-halves">

                                       <div class="columns portfolio-item">
                                       <div class="item-wrap">
                                               <a href="portfolio.html">
                                             <img alt="" src="images/portfolio/geometrics.jpg">
                                             <div class="overlay"></div>
                                             <div class="link-icon"><i class="fa fa-link"></i></div>
                                          </a>
                                                <div class="portfolio-item-meta">
                                                   <h5><a href="portfolio.html">Geometrics</a></h5>
                                             <p>Illustration</p>
                                                </div>
                                       </div>
                                        </div>

                                    <div class="columns portfolio-item">
                                       <div class="item-wrap">
                                               <a href="portfolio.html">
                                             <img alt="" src="images/portfolio/console.jpg">
                                             <div class="overlay"></div>
                                             <div class="link-icon"><i class="fa fa-link"></i></div>
                                          </a>
                                                <div class="portfolio-item-meta">
                                                   <h5><a href="portfolio.html">Console</a></h5>
                                             <p>Web Development</p>
                                                </div>
                                       </div>
                                        </div>

                                    <div class="columns portfolio-item s-first">
                                       <div class="item-wrap">
                                               <a href="portfolio.html">
                                             <img alt="" src="images/portfolio/camera-man.jpg">
                                             <div class="overlay"></div>
                                             <div class="link-icon"><i class="fa fa-link"></i></div>
                                          </a>
                                                <div class="portfolio-item-meta">
                                                   <h5><a href="portfolio.html">Camera Man</a></h5>
                                             <p>Photography</p>
                                                </div>
                                       </div>
                                        </div>

                                    <div class="columns portfolio-item">
                                       <div class="item-wrap">
                                               <a href="portfolio.html">
                                             <img alt="" src="images/portfolio/into-the-light.jpg">
                                             <div class="overlay"></div>
                                             <div class="link-icon"><i class="fa fa-link"></i></div>
                                          </a>
                                                <div class="portfolio-item-meta">
                                                   <h5><a href="portfolio.html">Into The Light</a></h5>
                                             <p>Branding</p>
                                                </div>
                                       </div>
                                        </div>

                                 </div>

                              </div>

                           </section> <!-- Works Section End-->
                """)
                SiteFooter()
            }
        )
    }
}
