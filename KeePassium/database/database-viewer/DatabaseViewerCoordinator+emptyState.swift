//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    final class EmptySpaceDecorator: GroupViewerEmptySpaceDecorator {
        private let permissions: DatabaseViewerItemPermissions
        private weak var coordinator: DatabaseViewerCoordinator?

        init(permissions: DatabaseViewerItemPermissions, coordinator: DatabaseViewerCoordinator) {
            self.permissions = permissions
            self.coordinator = coordinator
        }

        func getEmptyGroupConfiguration() -> UIContentUnavailableConfiguration? {
            var config = UIContentUnavailableConfiguration.empty()
            config.text = LString.titleThisGroupIsEmpty
            config.textProperties.color = .placeholderText
            config.image = .symbol(.folder)
            config.imageProperties.maximumSize = CGSize(width: 0, height: 64)
            config.imageProperties.tintColor = .placeholderText

            if permissions.contains(.createEntry) {
                var createEntryButton = UIButton.Configuration.plain()
                createEntryButton.title = LString.titleNewEntry
                createEntryButton.imagePadding = 8
                createEntryButton.image = .symbol(.docBadgePlus)
                config.button = createEntryButton
                config.buttonProperties.primaryAction = UIAction { [weak self] _ in
                    self?.coordinator?._showEntryCreator()
                }
            }
            if permissions.contains(.createGroup) {
                var createGroupButton = UIButton.Configuration.plain()
                createGroupButton.title = LString.titleNewGroup
                createGroupButton.imagePadding = 8
                createGroupButton.image = .symbol(.folderBadgePlus)
                config.secondaryButton = createGroupButton
                config.secondaryButtonProperties.primaryAction = UIAction { [weak self] _ in
                    self?.coordinator?._showGroupEditor(.create(smart: false))
                }
            }
            return config
        }

        func getNothingFoundConfiguration() -> UIContentUnavailableConfiguration? {
            var config = UIContentUnavailableConfiguration.search()
            config.textProperties.color = .placeholderText
            config.imageProperties.tintColor = .placeholderText
            return config
        }
    }
}
