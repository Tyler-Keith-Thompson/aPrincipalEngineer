//
//  OpenFGABatchCheckResponse.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/8/24.
//

import Vapor

struct OpenFGABatchCheckResponse: Content, Hashable {
    struct Result: Content, Hashable {
        private struct DynamicCodingKeys: CodingKey {
            // Use for string-keyed dictionary
            var stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            // Use for integer-keyed dictionary
            var intValue: Int?
            init?(intValue: Int) { nil }
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

            var tempArray = [OpenFGACheckResponse]()

            for key in container.allKeys.compactMap({ DynamicCodingKeys(stringValue: $0.stringValue) }) {
                let decodedObject = try container.decode(OpenFGACheckResponse.self, forKey: key)
                tempArray.append(decodedObject)
            }

            responses = tempArray
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: DynamicCodingKeys.self)
            for response in responses {
                if let id = response.id, let key = DynamicCodingKeys(stringValue: id.uuidString) {
                    try container.encode(response, forKey: key)
                }
            }
        }
        
        let responses: [OpenFGACheckResponse]
        
        init(responses: [OpenFGACheckResponse]) {
            self.responses = responses
        }
    }
    let result: Result
}
