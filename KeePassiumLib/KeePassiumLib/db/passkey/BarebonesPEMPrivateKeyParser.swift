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

final class BarebonesPEMPrivateKeyParser {
    private static let log = Logger(subsystem: "com.keepassium.crypto", category: "BarebonesPEMParser")
    private static let pemHeader = "-----BEGIN PRIVATE KEY-----"
    private static let pemFooter = "-----END PRIVATE KEY-----"

    static func parse(
        pemRepresentation pem: String,
        expectedPrefix: Data? = nil,
        prefixLength: Int? = nil
    ) throws -> Data {
        assert(
            expectedPrefix != nil || prefixLength != nil,
            "Either expectedPrefix or prefixLength must be defined"
        )

        let pem = pem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard pem.hasPrefix(pemHeader),
              pem.hasSuffix(pemFooter)
        else {
            log.debug("Missing PEM header/footer")
            throw CryptoKitError.invalidParameter
        }
        let noisyBase64String = pem
            .dropFirst(pemHeader.count)
            .dropLast(pemFooter.count)

        guard let asn1Data = Data(base64Encoded: String(noisyBase64String), options: .ignoreUnknownCharacters)
        else {
            log.debug("Failed to parse Base64 data")
            throw CryptoKitError.invalidParameter
        }

        let offset: Int
        if let expectedPrefix {
            guard asn1Data.starts(with: expectedPrefix) else {
                log.debug("ASN1 does not match the expected prefix")
                throw CryptoKitError.invalidParameter
            }
            offset = expectedPrefix.count
        } else if let prefixLength {
            offset = prefixLength
        } else {
            assertionFailure()
            throw CryptoKitError.invalidParameter
        }
        let rawKeyRepresentation = asn1Data.dropFirst(offset)
        return rawKeyRepresentation
    }
}
