//
//  BlogHeader.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/4/24.
//

import Elementary

struct BlogHeader: HTML {
    let blog: BlogPost
    
    var content: some HTML {
        a(.href("/blog/\(blog.id)")) { h1 { blog.title } }
        span {
            strong { blog.createdAt.flatMap { $0.formatted(date: .abbreviated, time: .omitted) + " " } ?? "" }
            for tag in blog.tags {
                strong { "/ " }
                tag
                " "
            }
        }
    }
}
