//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator: DatabaseSaving {
    func canCancelSaving(databaseFile: DatabaseFile) -> Bool {
        return false
    }

    func didCancelSaving(databaseFile: DatabaseFile) {
        refresh()
    }

    func didSave(databaseFile: DatabaseFile) {
        refresh()
    }

    func didFailSaving(databaseFile: DatabaseFile) {
        refresh()
    }

    func didRelocate(databaseFile: DatabaseFile, to newURL: URL) {
        delegate?.didRelocateDatabase(databaseFile, to: newURL)
    }

    func getDatabaseSavingErrorParent() -> UIViewController {
        return _presenterForModals
    }

    func getDiagnosticsHandler() -> (() -> Void)? {
        return _showDiagnostics
    }
}
