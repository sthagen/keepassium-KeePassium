//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import CryptoKit
import OSLog
import Security

private let log = Logger(subsystem: "com.keepassium.crypto", category: "RS256")

final class RS256PrivateKey {
    static let prefixLength = 26
    static let keySizeInBits = NSNumber(value: 2048)
    private let secKey: SecKey

    init(pemRepresentation pem: String) throws {
        let derData = try BarebonesPEMPrivateKeyParser.parse(
            pemRepresentation: pem,
            expectedPrefix: nil,
            prefixLength: Self.prefixLength
        )

        let options: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits: Self.keySizeInBits,
            kSecReturnPersistentRef: false
        ]
        var cfError: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(derData as CFData, options as CFDictionary, &cfError) else {
            let error = cfError!.takeRetainedValue() as Error
            log.error("Failed to parse as RSA private key: \(error.localizedDescription)")
            throw error
        }
        self.secKey = key
    }

    func signature(for data: Data) throws -> Data {
        var cfError: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            secKey,
            .rsaSignatureMessagePKCS1v15SHA256,
            data as CFData,
            &cfError
        ) else {
            let error = cfError!.takeRetainedValue() as Error
            log.error("Failed to parse as RSA private key: \(error.localizedDescription)")
            throw error
        }
        return signature as Data
    }
}
