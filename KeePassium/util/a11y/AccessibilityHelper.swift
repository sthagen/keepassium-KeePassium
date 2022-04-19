//  KeePassium Password Manager
//  Copyright © 2018–2022 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

class AccessibilityHelper {
    
    public static func decorateAccessibilityLabel(
        premiumFeature name: String?,
        isEnabled: Bool
    ) -> String? {
        guard let premiumFeatureName = name else {
            return nil
        }
        if isEnabled {
            return premiumFeatureName
        } else {
            return String.localizedStringWithFormat(
                "%@ (%@)",
                premiumFeatureName,
                LString.premiumFeatureGenericTitle)
        }
    }
}
