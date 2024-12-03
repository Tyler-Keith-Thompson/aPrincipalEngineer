//
//  DigestExtensions.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Foundation
import Crypto

extension Digest {
    /// Number of bits in the hash digest.
    @inlinable public static var bitCount: Int { byteCount * 8 }

    /// Truncate the Digest to a specific length in bits.
    /// - Parameter bitLen: The desired bit length.
    /// - Returns: A new Data object that has been truncated to bitLen bits.
    @inlinable public func truncateBitLen(_ bitLen: Int) -> Data {
        let byteLen = (bitLen + 7) / 8
        let data = Data(self)
        guard byteLen <= data.count else {
            return data
        }

        var result = data.prefix(byteLen)

        if bitLen % 8 != 0 {
            let lastByteIndex = byteLen - 1
            let mask: UInt8 = ~(0xFF >> (UInt(bitLen) % 8))
            result[lastByteIndex] &= mask
        }

        return result
    }
}

extension Digest {
    // Performant method for hex encoding a digest
    // Don't attempt to refactor from an SO answer or a string formatter...they're very slow
    // 48 is the ascii code point for "0"
    // 97 is the ascii code point for "a" and 87 is used because the nibble > 10
    @inline(__always) func hexEncodedString() -> String {
        String(unsafeUninitializedCapacity: 2 * Self.byteCount) { ptr -> Int in
            if var p = ptr.baseAddress {
                for byte in self {
                    let highNibble = byte >> 4
                    let lowNibble = byte & 0x0F

                    p[0] = highNibble < 10 ? (highNibble + 48) : (highNibble + 87)
                    p[1] = lowNibble < 10 ? (lowNibble + 48) : (lowNibble + 87)

                    p += 2
                }
            }
            return 2 * Self.byteCount
        }
    }
}
