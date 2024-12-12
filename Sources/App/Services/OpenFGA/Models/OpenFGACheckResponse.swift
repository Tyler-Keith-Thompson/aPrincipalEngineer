//
//  OpenFGACheckResponse.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/7/24.
//

import Foundation
import Logging

struct OpenFGACheckResponse: Codable, Hashable {
    let allowed: Bool
    let resolution: String?
    let id: UUID?
    
    enum CodingKeys: CodingKey {
        case allowed
        case resolution
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        allowed = try container.decode(Bool.self, forKey: .allowed)
        resolution = try container.decodeIfPresent(String.self, forKey: .resolution)
        
        id = container.codingPath.last.flatMap { UUID(uuidString: $0.stringValue) }
    }
    
    init(allowed: Bool, resolution: String? = nil, id: UUID? = nil) {
        self.allowed = allowed
        self.resolution = resolution
        self.id = id
    }
}
