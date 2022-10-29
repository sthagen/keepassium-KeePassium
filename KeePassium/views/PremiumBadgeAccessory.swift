//  KeePassium Password Manager
//  Copyright © 2018-2022 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

final class PremiumBadgeAccessory: UIImageView {
    required init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        image = UIImage(asset: .premiumFeatureBadge)
        contentMode = .scaleAspectFill
        accessibilityLabel = LString.premiumFeatureGenericTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}
