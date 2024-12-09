//
//  Email.swift
//
//
//  Created by Tyler Thompson on 2/4/23.
//

import Foundation
import Parsing
import Algorithms

public struct Email: Codable, Sendable, CustomStringConvertible {
    enum ParserError: Error {
        case emailTooLong
    }

    private let localPartToken: Token
    private let domainPartToken: Token

    public var localPart: String {
        localPartToken.description
    }

    public var domainPart: String {
        domainPartToken.description
    }

    public let mailbox: String
    
    public var description: String { mailbox }

    @inlinable public var address: String {
        "\(localPart)@\(domainPart)"
    }

    public var semantic: SemanticEmail {
        SemanticEmail(localPart: localPartToken,
                      domainPart: domainPartToken,
                      mailbox: mailbox)
    }

    public init(_ emailStr: String) throws {
        let email = try Email.parser().parse(emailStr)
        mailbox = email.mailbox
        localPartToken = email.localPartToken
        domainPartToken = email.domainPartToken
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let emailStr = try container.decode(String.self)
        try self.init(emailStr)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(mailbox)
    }

    init(localPart: Token, domainPart: Token, mailbox: String) {
        localPartToken = localPart
        domainPartToken = domainPart
        self.mailbox = mailbox
    }
}

extension Email {
    @inlinable public static func parser() -> some Parser<Substring, Email> {
        EmailParser()
    }

    public struct EmailParser: Parser {
        public init() { }
        
        public func parse(_ input: inout Substring) throws -> Email {
            let mailbox = "\(input)"
            let (local, domain) = try Mailbox.parser().parse(&input)

            if local.description.count + domain.description.count + 1 /*@*/ > 254 {
                throw ParserError.emailTooLong
            }

            return Email(localPart: local, domainPart: domain, mailbox: mailbox)
        }
    }
}
