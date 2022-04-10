//
//  Footer.swift
//  
//
//  Created by Tyler Thompson on 4/8/22.
//

import Plot
import Publish

@available(macOS 10.12, *)
struct SiteFooter: Component {
    let context: PublishingContext<APrincipalEngineer>

    var body: Component {
        ComponentGroup {
            Footer {
                Div {
                    Div {
                        List {
                            ListItem { Link("Home.", url: context.site.url.appendingPathComponent("index.html").absoluteString) }
                            ListItem { Link("Blog.", url: context.site.url.appendingPathComponent("blog").appendingPathComponent("index.html").absoluteString) }
                            ListItem { Link("About.", url: context.site.url.appendingPathComponent("about").appendingPathComponent("index.html").absoluteString) }
//                            ListItem { Link("Contact.", url: context.site.url.appendingPathComponent("contact").appendingPathComponent("index.html").absoluteString) }
                        }.class("footer-nav")
                        Div {
                            Paragraph {
                                Text("Generated using ")
                                Link("Publish", url: "https://github.com/johnsundell/publish")
                                Text("\n | \n")
                                Link("Original Site Template Copyright &copy; 2014 Sparrow", url: "http://www.styleshout.com/")
                            }
                        }.class("align-center")
                    }.class("twelve columns")
                    Div {
                        Link("Go To Top", url: "#")
                            .attribute(named: "title", value: "Back to Top")
                    }.id("go-top")
                        .style("display: block;")
                }.class("row")
            }
            ComponentGroup(html: #"""
            <!-- Java Script
            ================================================== -->
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
            <script>window.jQuery || document.write('<script src="js/jquery-1.10.2.min.js"><\/script>')</script>
            <script type="text/javascript" src="js/jquery-migrate-1.2.1.min.js"></script>

            <script src="js/jquery.flexslider.js"></script>
            <script src="js/doubletaptogo.js"></script>
            <script src="js/init.js"></script>
            """#)
        }
    }
}
