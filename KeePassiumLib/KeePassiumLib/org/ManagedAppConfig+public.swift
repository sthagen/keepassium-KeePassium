//  KeePassium Password Manager
//  Copyright © 2018-2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension ManagedAppConfig {
    public var isRequireAppPasscodeSet: Bool {
        getBoolIfLicensed(.requireAppPasscodeSet) ?? false
    }

    public var minimumAppPasscodeEntropy: Int? {
        getIntIfLicensed(.minimumAppPasscodeEntropy)
    }

    public var minimumDatabasePasswordEntropy: Int? {
        getIntIfLicensed(.minimumDatabasePasswordEntropy)
    }

    public var isPasswordAuditAllowed: Bool {
        return getBoolIfLicensed(.allowPasswordAudit) ?? true
    }

    public var isFaviconDownloadAllowed: Bool {
        return getBoolIfLicensed(.allowFaviconDownload) ?? true
    }
}
