//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryFinderCoordinator {
    class ToolbarDecorator: EntryFinderToolbarDecorator {
        weak var coordinator: EntryFinderCoordinator?

        func getToolbarItems() -> [UIBarButtonItem]? {
            return nil
        }

        func getLeadingItemGroups() -> [UIBarButtonItemGroup]? {
            return nil
        }

        func getTrailingItemGroups() -> [UIBarButtonItemGroup]? {
            return nil
        }
    }
}

extension EntryFinderCoordinator {
    private func didPressLockDatabase() {
        lockDatabase()
    }

    private func didPressSearch() {
        _entryFinderVC.activateManualSearch()
    }
}
