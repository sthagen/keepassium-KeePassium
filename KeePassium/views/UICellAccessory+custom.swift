//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension UICellAccessory {
    static func premiumFeatureIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: .symbol(
            .starFill,
            accessibilityLabel: LString.premiumFeatureGenericTitle
        ))
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = [.staticText]
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .default)
        return UICellAccessory.customView(configuration: .init(
            customView: imageView,
            placement: .trailing(),
            tintColor: .systemYellow
        ))
    }

    static func passkeyPresenceIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: .symbol(
            .passkey,
            tint: .secondaryLabel,
            accessibilityLabel: LString.A11y.containsPasskey
        ))
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = [.staticText]
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .default)
        return UICellAccessory.customView(configuration: .init(customView: imageView, placement: .trailing()))
    }

    static func attachmentPresenceIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: .symbol(
            .paperclip,
            tint: .secondaryLabel,
            accessibilityLabel: LString.A11y.containsAttachments
        ))
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = [.staticText]
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .default)
        return UICellAccessory.customView(configuration: .init(customView: imageView, placement: .trailing()))
    }

    static func otpPresenceIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: .symbol(
            .oneTimePassword,
            tint: .secondaryLabel,
            accessibilityLabel: LString.fieldOTP
        ))
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = [.staticText]
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .default)
        return UICellAccessory.customView(configuration: .init(customView: imageView, placement: .trailing()))
    }

    static func otpCode(
        generator: TOTPGenerator,
        mode displayMode: OTPDisplayMode,
        onTap: ((_ otpCode: String) -> Void)?
    ) -> UICellAccessory {
        let accessoryView: UIView
        switch displayMode {
        case .protected:
            accessoryView = OTPButton(generator: generator, protected: true, onTap: onTap)
        case .visible, .prominent:
            accessoryView = OTPButton(generator: generator, protected: false, onTap: onTap)
        }
        accessoryView.accessibilityLabel = LString.fieldOTP
        return UICellAccessory.customView(configuration: .init(
            customView: accessoryView,
            placement: .trailing(displayed: .always),
            maintainsFixedSize: false
        ))
    }

    static func smartGroupIndicator(isAccessibilityElement: Bool = true) -> UICellAccessory {
        let imageView = UIImageView(image: .symbol(
            .smartGroup,
            tint: .secondaryLabel,
            accessibilityLabel: LString.titleSmartGroup
        ))
        imageView.isAccessibilityElement = isAccessibilityElement
        imageView.accessibilityTraits = [.staticText]
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .default)
        return UICellAccessory.customView(configuration: .init(customView: imageView, placement: .trailing()))
    }
}
