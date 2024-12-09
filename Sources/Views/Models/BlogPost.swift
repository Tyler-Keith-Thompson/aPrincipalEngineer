//
//  BlogPost.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/3/24.
//
import Foundation

public struct BlogPost: Sendable {
    let id: String
    let tags: [String]
    let title: String
    let createdAt: Date?
    let author: User?
    let description: String
    let content: String
    
    public init(id: String, tags: [String], title: String, createdAt: Date?, author: User?, description: String, content: String) {
        self.id = id
        self.tags = tags
        self.title = title
        self.createdAt = createdAt
        self.author = author
        self.description = description
        self.content = content
    }
}
