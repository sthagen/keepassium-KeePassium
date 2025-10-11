//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import CryptoKit
import Foundation
import OSLog

private let log = Logger(subsystem: "com.keepassium.crypto", category: "Curve25519")

private let rawPrivateKeySize = 32

private let ed25519PrivateKeyASN1Prefix = Data(
// swiftlint:disable collection_alignment
    [0x30, 0x2E,
        0x02, 0x01, 0x00,
        0x30, 0x05,
            0x06, 0x03,
                0x2B, 0x65, 0x70,
        0x04, 0x22,
            0x04, 0x20
    ])
// swiftlint:enable collection_alignment

extension Curve25519.Signing.PrivateKey {
    init(pemRepresentation pem: String) throws {
        let rawKeyRepresentation = try BarebonesPEMPrivateKeyParser.parse(
            pemRepresentation: pem,
            expectedPrefix: ed25519PrivateKeyASN1Prefix)
        guard rawKeyRepresentation.count == rawPrivateKeySize else {
            log.debug("Unexpected raw key size: \(rawKeyRepresentation.count)")
            throw CryptoKitError.incorrectKeySize
        }
        try self.init(rawRepresentation: rawKeyRepresentation)
    }
}
