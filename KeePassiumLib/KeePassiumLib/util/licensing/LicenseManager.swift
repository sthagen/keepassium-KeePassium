//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

public enum BusinessLicenseStatus {
    case missing
    case invalid
    case valid
    case expired
}

public final class LicenseManager {
    public static let shared = LicenseManager()

    private enum LicenseKeyFormat {
        case version1
        case unknown
    }

    private var cachedLicenseStatus: BusinessLicenseStatus?

    public var hasAcceptableBusinessLicense: Bool {
        switch businessLicenseStatus {
        case .missing:
            return false
        case .valid, .expired, .invalid:
            return true
        }
    }
    public var businessLicenseStatus: BusinessLicenseStatus {
        if let cachedLicenseStatus {
            return cachedLicenseStatus
        }

        let licenseStatus = _evaluateLicenseStatus()
        cachedLicenseStatus = licenseStatus
        return licenseStatus
    }

    internal func checkBusinessLicense() {
        cachedLicenseStatus = _evaluateLicenseStatus()
    }

    private func _evaluateLicenseStatus() -> BusinessLicenseStatus {
        guard let licenseKey = ManagedAppConfig.shared.license else {
            return .missing
        }

        let keyFormat = getLicenseKeyFormat(licenseKey)
        switch keyFormat {
        case .version1:
            return checkLicenseV1(licenseKey)
        case .unknown:
            Diag.error("Business license key is misformatted")
            return .invalid
        }
    }

    private func getLicenseKeyFormat(_ licenseKey: String) -> LicenseKeyFormat {
        if let _ = getLicenseDataV1(from: licenseKey) {
            return .version1
        }
        return .unknown
    }
}

extension LicenseManager {
    private static let proofListFileName = "v1-proofs.sha256"

    // swiftlint:disable:next comma
    private static let expiredIndices = Set<Int>([0,1,2,5,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22])

    private enum LicenseV1 {
        static let keyLength = 32 
        static let proofSize = SHA256_SIZE
    }

    private func getLicenseDataV1(from licenseKey: String) -> ByteArray? {
        guard licenseKey.count == LicenseV1.keyLength,
              let licenseData = ByteArray(hexString: licenseKey)
        else {
            return nil
        }
        return licenseData
    }

    private func checkLicenseV1(_ licenseKey: String) -> BusinessLicenseStatus {
        guard let licenseData = getLicenseDataV1(from: licenseKey) else {
            Diag.warning("Unexpected license key format")
            return .invalid
        }
        let licenseKeyHash = licenseData.sha256

        let proofListURL = Bundle.framework.url(
            forResource: Self.proofListFileName,
            withExtension: "",
            subdirectory: "")
        guard let proofListURL,
              let proofList = try? ByteArray(contentsOf: proofListURL)
        else {
            Diag.error("License proof list is missing")
            return .invalid
        }

        let inputStream = proofList.asInputStream()
        inputStream.open()
        defer {
            inputStream.close()
        }
        var index = 0
        while inputStream.hasBytesAvailable {
            guard let aProof = inputStream.read(count: LicenseV1.proofSize) else {
                Diag.error("License hash list is corrupted")
                return .invalid
            }
            if aProof == licenseKeyHash {
                if Self.expiredIndices.contains(index) {
                    Diag.debug("License key is expired [hashPrefix: \(licenseKeyHash.prefix(8).asHexString)]")
                    return .expired
                } else {
                    Diag.debug("License key is valid [hashPrefix: \(licenseKeyHash.prefix(8).asHexString)]")
                    return .valid
                }
            }
            index += 1
        }
        Diag.error("License key invalid [hash: \(licenseKeyHash.asHexString)]")
        return .invalid
    }
}
