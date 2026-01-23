//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import UIKit

private protocol DeprecatedApplicationWindows {
    var deprecatedWindows: [UIWindow] { get }
}

extension UIApplication: DeprecatedApplicationWindows {
    public var currentActiveScene: UIWindowScene? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }

    @available(*, deprecated)
    var deprecatedWindows: [UIWindow] { self.windows }

    public var firstKeyWindow: UIWindow? {
        let keyWindow = (self as DeprecatedApplicationWindows)
            .deprecatedWindows
            .first(where: { $0.isKeyWindow })
        return keyWindow
    }
}
