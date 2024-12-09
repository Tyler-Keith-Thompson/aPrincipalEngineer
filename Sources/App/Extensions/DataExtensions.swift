//
//  DataExtensions.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/2/24.
//

import Foundation

extension Data {
    /// Creates a Data instance safely from the contiguous bytes.
    /// This avoids unnecessary copying by using `withUnsafeBytes` to directly initialize the `Data` object.
    init?<D: ContiguousBytes>(unsafeContiguousBytes: D) {
        self = unsafeContiguousBytes.withUnsafeBytes { bytes in
            Data(bytes: bytes.baseAddress!, count: bytes.count)
        }
    }
}
