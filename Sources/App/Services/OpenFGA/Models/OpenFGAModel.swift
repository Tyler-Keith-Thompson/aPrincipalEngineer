//
//  OpenFGAModel.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Fluent
import Foundation

protocol OpenFGAModel {
    associatedtype Relation: RawRepresentable<String>
    var openFGATypeName: String { get }
    var openFGAID: String { get throws }
}

extension OpenFGAModel where Self: Fluent.Model {
    var openFGATypeName: String {
        String(describing: Self.self).reduce(into: "") { result, character in
            if character.isUppercase {
                // Add an underscore if not at the start of the string
                if !result.isEmpty {
                    result.append("_")
                }
                // Append the lowercase version of the character
                result.append(character.lowercased())
            } else {
                // Append the character as is
                result.append(character)
            }
        }
    }
}

extension OpenFGAModel where Self: Fluent.Model, IDValue == UUID {
    var openFGAID: String {
        get throws {
            try requireID().uuidString.lowercased()
        }
    }
}
