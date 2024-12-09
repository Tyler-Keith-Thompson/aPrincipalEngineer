//
//  OpenFGATuple.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

struct OpenFGATuple: Codable, Hashable {
    struct OpenFGATypeTuple: Codable, Hashable {
        enum Error: Swift.Error {
            case invalidTypeTuple
        }
        let type: String
        let id: String
        
        init(type: String, id: String) throws {
            guard !type.contains(":") else {
                throw Error.invalidTypeTuple
            }
            self.type = type
            self.id = id
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            let components = str.components(separatedBy: ":")
            guard components.count >= 2, let unwrappedType = components.first else {
                throw Error.invalidTypeTuple
            }
            type = unwrappedType
            id = components.dropFirst().joined(separator: ":")
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode("\(type):\(id)")
        }
    }
    
    let user: OpenFGATypeTuple
    let relation: String
    let object: OpenFGATypeTuple
}

extension OpenFGATuple {
    init<Object: OpenFGAModel>(user: some OpenFGAModel, relation: Object.Relation, object: Object) throws {
        try self.init(user: .init(type: user.openFGATypeName, id: user.openFGAID),
                      relation: relation.rawValue,
                      object: .init(type: object.openFGATypeName, id: object.openFGAID))
    }
    
    init<Object: OpenFGAModel>(user: OpenFGATypeTuple, relation: Object.Relation, object: Object) throws {
        try self.init(user: user,
                      relation: relation.rawValue,
                      object: .init(type: object.openFGATypeName, id: object.openFGAID))
    }
}
