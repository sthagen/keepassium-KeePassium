//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

enum AutoFillItemKind {
    case passkey
    case otp

    static func fromAutoFillMode(_ mode: AutoFillMode?) -> Self? {
        switch mode {
        case .credentials, .text:
            return nil
        case .passkeyRegistration:
            return .passkey
        case .passkeyAssertion(let allowPasswords):
            if allowPasswords {
                return nil
            } else {
                return .passkey
            }
        case .oneTimeCode:
            return .otp
        case .none:
            return nil
        }
    }

    func matches(_ item: DatabaseItem) -> Bool {
        guard let entry2 = item as? Entry2 else { return false }
        switch self {
        case .otp:
            return entry2.hasValidTOTP
        case .passkey:
            switch Passkey.checkPresence(in: entry2) {
            case .noPasskey:
                return false
            case .passkeyPresent:
                return true
            }
        }
    }
}
