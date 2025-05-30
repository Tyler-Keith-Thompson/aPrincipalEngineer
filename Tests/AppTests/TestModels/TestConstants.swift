//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift WebAuthn open source project
//
// Copyright (c) 2023 the Swift WebAuthn project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import WebAuthn
import Foundation

struct TestConstants {
    /// Byte representation of string "randomStringFromServer"
    static let mockChallenge: [UInt8] = "72616e646f6d537472696e6746726f6d536572766572".hexadecimal!
    static let mockCredentialID: [UInt8] = [0, 1, 2, 3, 4]
}

extension String {
    /// Create `[UInt8]` from hexadecimal string representation
    var hexadecimal: [UInt8]? {
        let hex = self
        guard hex.count.isMultiple(of: 2) else {
            return nil
        }

        let chars = hex.map { $0 }
        let bytes = stride(from: 0, to: chars.count, by: 2)
            .map { String(chars[$0]) + String(chars[$0 + 1]) }
            .compactMap { UInt8($0, radix: 16) }

        guard hex.count / bytes.count == 2 else { return nil }

        return bytes
    }
}

extension Data {
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}
