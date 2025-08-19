//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension AutoFillCoordinator {
    internal func _showCrashReport() {
        StoreReviewSuggester.registerEvent(.trouble)

        let crashReportVC = CrashReportVC.instantiateFromStoryboard()
        crashReportVC.delegate = self
        _router.push(crashReportVC, animated: false, onPop: nil)
    }
}

extension AutoFillCoordinator: CrashReportDelegate {
    func didPressDismiss(in crashReport: CrashReportVC) {
        Settings.current.isAutoFillFinishedOK = true
        _router.pop(animated: true)
    }
}
