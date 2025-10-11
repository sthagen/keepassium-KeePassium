//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension UICellAccessory {
    static func passkeyPresenceIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: .symbol(
            .passkey,
            tint: .secondaryLabel,
            accessibilityLabel: LString.fieldPasskey
        ))
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .default)
        return UICellAccessory.customView(configuration: .init(customView: imageView, placement: .trailing()))
    }

    static func otpPresenceIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: .symbol(
            .oneTimePassword,
            tint: .secondaryLabel,
            accessibilityLabel: LString.fieldOTP
        ))
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .default)
        return UICellAccessory.customView(configuration: .init(customView: imageView, placement: .trailing()))
    }
}
