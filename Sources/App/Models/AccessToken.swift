//
//  AccessToken.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import JWT
import Vapor
import DependencyInjection
import Crypto

struct AccessToken: JWTPayload, Equatable {
    let iss: IssuerClaim
    let aud: AudienceClaim
    let exp: ExpirationClaim
    let iat: IssuedAtClaim
    let sub: SubjectClaim
    let email: String?
    let emailVerified: Bool?

    func verify(using _: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
    
    static func == (lhs: AccessToken, rhs: AccessToken) -> Bool {
        lhs.iss == rhs.iss
        && lhs.aud == rhs.aud
        && lhs.sub == rhs.sub
        && lhs.email == rhs.email
        && lhs.emailVerified == rhs.emailVerified
    }
}

struct PseudonymousIdentifierOptions: Codable {
    let symmetricKey: SymmetricKey
    let nonce: AES.GCM.Nonce
    enum CodingKeys: String, CodingKey {
        case symmetricKey
        case nonce
    }
    
    init(symmetricKey: SymmetricKey, nonce: AES.GCM.Nonce) {
        self.symmetricKey = symmetricKey
        self.nonce = nonce
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let symmetricKeyData = try container.decode(String.self, forKey: .symmetricKey)
        guard let symmetricKeyData = Data(base64Encoded: symmetricKeyData) else {
            throw DecodingError.dataCorruptedError(forKey: .symmetricKey, in: container, debugDescription: "Cannot create symmetric key from base64 encoded string")
        }
        symmetricKey = SymmetricKey(data: symmetricKeyData)
        let nonceData = try container.decode(String.self, forKey: .nonce)
        guard let nonceData = Data(base64Encoded: nonceData) else {
            throw DecodingError.dataCorruptedError(forKey: .nonce, in: container, debugDescription: "Cannot create nonce from base64 encoded string")
        }
        nonce = try AES.GCM.Nonce(data: nonceData)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let symmetricKeyData = Data(unsafeContiguousBytes: symmetricKey) else {
            throw EncodingError.invalidValue(symmetricKey, .init(codingPath: [CodingKeys.symmetricKey], debugDescription: "Cannot get create data from contiguous bytes of symmetric key"))
        }
        try container.encode(symmetricKeyData.base64EncodedString(), forKey: .symmetricKey)
        try container.encode(Data(nonce).base64EncodedString(), forKey: .nonce)
    }
}

extension SubjectClaim {
    enum Error: Swift.Error {
        case cannotCombineSealedBoxData
    }
    init(user: User, clientID: String, cache: any Vapor.Cache) async throws {
        let pseudonymousIdentifierOptions: PseudonymousIdentifierOptions = try await {
            if let pseudonymousIdentifierOptions = try await cache.get("\(clientID)_psuedonymous_identifier_options", as: PseudonymousIdentifierOptions.self) {
                return pseudonymousIdentifierOptions
            } else {
                let options = PseudonymousIdentifierOptions(symmetricKey: SymmetricKey(size: .bits128),
                                                            nonce: .init())
                try await cache.set("\(clientID)_psuedonymous_identifier_options", to: options)
                return options
            }
        }()
        let sealedBox = try AES.GCM.seal(Data(user.requireID().uuidString.utf8), using: pseudonymousIdentifierOptions.symmetricKey, nonce: pseudonymousIdentifierOptions.nonce)
        guard let combined = sealedBox.combined else {
            throw Error.cannotCombineSealedBoxData
        }
        
        self.init(value: combined.base64EncodedString())
    }
}

extension AccessToken {
    enum Error: Swift.Error {
        case cannotRecoverUserID
    }
    func sign() async throws -> String {
        try await Container.userAuthenticatorKeyStore().sign(self)
    }
    
    func userID(cache: any Vapor.Cache) async throws -> UUID {
        guard let clientID = aud.value.first,
              let sealedBoxData = Data(base64Encoded: sub.value),
              let pseudonymousIdentifierOptions = try await cache.get("\(clientID)_psuedonymous_identifier_options", as: PseudonymousIdentifierOptions.self),
              let idString = String(data: try AES.GCM.open(try AES.GCM.SealedBox(combined: sealedBoxData), using: pseudonymousIdentifierOptions.symmetricKey), encoding: .utf8),
              let id = UUID(uuidString: idString) else { throw Error.cannotRecoverUserID }
        
        return id
    }
}
