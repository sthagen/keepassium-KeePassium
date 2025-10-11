//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    final class ToolbarDecorator: GroupViewerToolbarDecorator {
        weak var group: Group?
        weak var coordinator: DatabaseViewerCoordinator?

        private let statusLabel: UILabel = {
            let label = UILabel()
            label.textColor = .primaryText
            label.font = .preferredFont(forTextStyle: .footnote)
            label.adjustsFontForContentSizeCategory = true
            label.textAlignment = .center
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.text = LString.statusCheckingDatabaseForExternalChanges
            return label
        }()
        private let statusLabelItem: UIBarButtonItem

        init(for group: Group?, coordinator: DatabaseViewerCoordinator? = nil) {
            self.group = group
            self.coordinator = coordinator
            self.statusLabelItem = UIBarButtonItem(customView: statusLabel)
        }

        func getLeftBarButtonItems(mode: GroupViewerToolbarMode) -> [UIBarButtonItem]? {
            switch mode {
            case .normal:
                return nil
            case .bulkEdit:
                return nil
            }
        }

        func getRightBarButtonItems(mode: GroupViewerToolbarMode) -> [UIBarButtonItem]? {
            guard let group, let coordinator else { return nil }
            switch mode {
            case let .normal(showsSearchResults):
                let groupActionsButton = UIBarButtonItem(
                    title: LString.titleGroupMenu,
                    image: .symbol(.ellipsisCircle))
                groupActionsButton.preferredMenuElementOrder = .fixed
                groupActionsButton.menu = makeGroupActionsMenu(
                    for: group,
                    isSearchMode: showsSearchResults,
                    at: groupActionsButton.asPopoverAnchor,
                    coordinator: coordinator
                )
                return [groupActionsButton]
            case .bulkEdit:
                let doneSelectReorderButton = UIBarButtonItem(systemItem: .done, primaryAction: UIAction {
                    [weak coordinator] _ in
                    coordinator?.didPressDoneBulkEditing()
                })
                return [doneSelectReorderButton]
            }
        }

        func getToolbarItems(mode: GroupViewerToolbarMode) -> [UIBarButtonItem]? {
            guard let group, let coordinator  else { return nil }

            switch mode {
            case let .normal(showsSearchResults):
                return makeNormalToolbar(
                    for: group,
                    isSearchMode: showsSearchResults,
                    coordinator: coordinator)
            case let .bulkEdit(showsSearchResults, selectedItems):
                return makeBulkEditToolbar(
                    for: selectedItems,
                    in: group,
                    isSearchMode: showsSearchResults,
                    coordinator: coordinator
                )
            }
        }
    }
}

extension DatabaseViewerCoordinator.ToolbarDecorator {
    private func makeNormalToolbar(
        for group: Group,
        isSearchMode: Bool,
        coordinator: DatabaseViewerCoordinator
    ) -> [UIBarButtonItem]? {
        var toolbarItems = [UIBarButtonItem]()
        let databaseToolsButton = UIBarButtonItem(
            title: LString.titleTools,
            image: .symbol(.wrenchAndScrewdriver)
        )
        databaseToolsButton.preferredMenuElementOrder = .fixed
        databaseToolsButton.menu = makeToolsMenu(
            for: group,
            isSearchMode: isSearchMode,
            popoverAnchor: databaseToolsButton.asPopoverAnchor,
            coordinator: coordinator
        )
        toolbarItems.append(databaseToolsButton)
        toolbarItems.append(.flexibleSpace())

        let status = coordinator._databaseUpdateCheckStatus
        switch status {
        case .idle:
            let reloadDatabaseButton = UIBarButtonItem(
                systemItem: .refresh,
                primaryAction: UIAction { [weak coordinator] _ in
                    coordinator?._reloadDatabase()
                }
            )
            reloadDatabaseButton.title = LString.actionReloadDatabase
            toolbarItems.append(reloadDatabaseButton)
        case .inProgress, .failed, .upToDate:
            UIView.transition(with: statusLabel, duration: 0.3, options: .transitionCrossDissolve) {
                [weak statusLabel] in
                statusLabel?.text = status.description
            }
            toolbarItems.append(statusLabelItem)
        }

        toolbarItems.append(.flexibleSpace())
        let appSettingsButton = UIBarButtonItem(
            title: LString.titleSettings,
            image: .symbol(.gearshape),
            primaryAction: UIAction { [weak coordinator] _ in
                coordinator?._showAppSettings()
            }
        )
        appSettingsButton.accessibilityIdentifier = "settings_button"
        toolbarItems.append(appSettingsButton)

        return toolbarItems
    }

    private func makeGroupActionsMenu(
        for group: Group,
        isSearchMode: Bool,
        at popoverAnchor: PopoverAnchor,
        coordinator: DatabaseViewerCoordinator
    ) -> UIMenu {
        var permissions = DatabaseViewerPermissionManager.getPermissions(
            for: group,
            in: coordinator._databaseFile)
        if coordinator._isSearchOngoing {
            permissions.remove(.reorderItems)
        }

        let createGroupAction = UIAction(
            title: LString.titleNewGroup,
            image: .symbol(.folderBadgePlus),
            attributes: permissions.contains(.createGroup) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._showGroupEditor(.create(smart: false))
            }
        )

        let createSmartGroupAction = UIAction(
            title: LString.titleNewSmartGroup,
            image: .symbol(.folderGridBadgePlus),
            attributes: permissions.contains(.createGroup) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._showGroupEditor(.create(smart: true))
            }
        )

        let createEntryAction = UIAction(
            title: LString.titleNewEntry,
            image: .symbol(.docBadgePlus),
            attributes: permissions.contains(.createEntry) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._showEntryCreator()
            }
        )

        let editGroupAction = UIAction(
            title: LString.titleEditGroup,
            image: .symbol(.squareAndPencil),
            attributes: permissions.contains(.editItem) ? [] : [.disabled],
            handler: { [weak coordinator, weak group] _ in
                guard let coordinator, let group else { return }
                coordinator._showGroupEditor(.modify(group: group))
            }
        )

        let selectItemsAction = UIAction(
            title: LString.actionSelect,
            image: .symbol(.checkmarkCircle),
            attributes: permissions.contains(.selectItems) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._startSelecting()
            }
        )

        return UIMenu.make(
            title: "",
            reverse: false,
            children: [
                createEntryAction,
                createGroupAction,
                coordinator._supportsSmartGroups ? createSmartGroupAction : nil,
                UIMenu(inlineChildren: [
                    editGroupAction,
                    selectItemsAction
                ]),
                makeListSettingsMenu(permissions: permissions, coordinator: coordinator)
            ]
        )
    }

    private func makeListSettingsMenu(
        permissions: DatabaseViewerItemPermissions,
        coordinator: DatabaseViewerCoordinator
    ) -> UIMenu {
        let currentDetail = Settings.current.entryListDetail
        let entrySubtitleActions = Settings.EntryListDetail.allValues.map { entryListDetail in
            UIAction(
                title: entryListDetail.title,
                state: (currentDetail == entryListDetail) ? .on : .off,
                handler: { [weak coordinator] _ in
                    Settings.current.entryListDetail = entryListDetail
                    coordinator?.refresh()
                }
            )
        }
        let entrySubtitleMenu = UIMenu.make(
            title: LString.titleEntrySubtitle,
            subtitle: currentDetail.title,
            reverse: false,
            options: [],
            children: entrySubtitleActions
        )

        let groupSortOrder = Settings.current.groupSortOrder
        let reorderItemsAction = UIAction(
            title: LString.actionReorderItems,
            image: .symbol(.arrowUpArrowDown),
            attributes: permissions.contains(.reorderItems) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._startReordering()
            }
        )

        let sortOrderMenuItems = UIMenu.makeDatabaseItemSortMenuItems(
            current: groupSortOrder,
            reorderAction: reorderItemsAction,
            handler: { [weak coordinator] newSortOrder in
                Settings.current.groupSortOrder = newSortOrder
                coordinator?.refresh()
            }
        )
        let sortOrderMenu = UIMenu.make(
            title: LString.titleSortOrder,
            subtitle: groupSortOrder.title,
            reverse: false,
            options: [],
            macOptions: [],
            children: sortOrderMenuItems
        )
        return UIMenu.make(
            title: "",
            options: [.displayInline],
            children: [sortOrderMenu, entrySubtitleMenu]
        )
    }

    private func makeToolsMenu(
        for group: Group,
        isSearchMode: Bool,
        popoverAnchor: PopoverAnchor,
        coordinator: DatabaseViewerCoordinator
    ) -> UIMenu {
        let permissions = DatabaseViewerPermissionManager.getPermissions(
            for: group,
            in: coordinator._databaseFile)

        let lockDatabaseAction = UIAction(
            title: LString.actionLockDatabase,
            image: .symbol(.lock),
            attributes: [.destructive],
            handler: { [weak coordinator] _ in
                coordinator?.closeDatabase(
                    shouldLock: true,
                    reason: .userRequest,
                    animated: true,
                    completion: nil
                )
            }
        )
        let printDatabaseAction = UIAction(
            title: LString.actionPrint,
            image: .symbol(.printer),
            attributes: permissions.contains(.printDatabase) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._showDatabasePrintDialog()
            }
        )
        let changeMasterKeyAction = UIAction(
            title: LString.actionChangeMasterKey,
            image: .symbol(.key),
            attributes: permissions.contains(.changeMasterKey) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._showMasterKeyChanger()
            }
        )
        let passwordAuditAction = UIAction(
            title: LString.titlePasswordAudit,
            image: .symbol(.networkBadgeShield),
            attributes: permissions.contains(.auditPasswords) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._showPasswordAudit()
            }
        )
        let faviconsDownloadAction = UIAction(
            title: LString.actionDownloadFavicons,
            image: .symbol(.wandAndStars),
            attributes: permissions.contains(.downloadFavicons) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._downloadFavicons()
            }
        )
        let passwordGeneratorAction = UIAction(
            title: LString.PasswordGenerator.titleRandomGenerator,
            image: .symbol(.dieFace3),
            handler: { [weak coordinator, popoverAnchor] _ in
                guard let coordinator else { return }
                coordinator._showPasswordGenerator(
                    at: popoverAnchor,
                    in: coordinator._topGroupViewer ?? coordinator._presenterForModals
                )
            }
        )

        let encryptionSettingsAction = UIAction(
            title: LString.titleEncryptionSettings,
            image: .symbol(.lockShield),
            attributes: permissions.contains(.changeEncryptionSettings) ? [] : [.disabled],
            handler: { [weak coordinator] _ in
                coordinator?._showEncryptionSettings()
            }
        )

        let frequentMenu = UIMenu.make(
            options: [.displayInline],
            children: [
                passwordGeneratorAction,
                passwordAuditAction,
                permissions.contains(.downloadFavicons) ? faviconsDownloadAction : nil,
                printDatabaseAction,
            ]
        )
        let rareMenu = UIMenu.make(
            options: [.displayInline],
            children: [
                changeMasterKeyAction,
                permissions.contains(.changeEncryptionSettings) ? encryptionSettingsAction : nil,
            ]
        )
        let lockMenu = UIMenu(options: [.displayInline], children: [lockDatabaseAction])

        return UIMenu.make(children: [frequentMenu, rareMenu, lockMenu])
    }
}

extension DatabaseViewerCoordinator.ToolbarDecorator {
    private func makeBulkEditToolbar(
        for selectedItems: [DatabaseItem],
        in parent: Group,
        isSearchMode: Bool,
        coordinator: DatabaseViewerCoordinator
    ) -> [UIBarButtonItem]? {
        let databaseFile = coordinator._databaseFile
        let permissions = DatabaseViewerPermissionManager.getPermissions(
            for: parent,
            in: databaseFile)

        var toolbarItems = [UIBarButtonItem]()
        if permissions.contains(.downloadFavicons) {
            let bulkFaviconDownloadButton = UIBarButtonItem(
                title: LString.actionDownloadFavicons,
                image: .symbol(.wandAndStars),
                primaryAction: UIAction { [weak coordinator] _ in
                    coordinator?.didPressBulkDownloadFavicons(for: selectedItems)
                }
            )
            bulkFaviconDownloadButton.isEnabled = selectedItems.contains(where: {
                guard let urlString = ($0 as? Entry2)?.resolvedURL else { return false }
                return URL.from(malformedString: urlString) != nil
            })
            toolbarItems.append(bulkFaviconDownloadButton)
        }

        toolbarItems.append(.flexibleSpace())
        let bulkMoveButton = UIBarButtonItem(
            title: LString.actionMove,
            image: .symbol(.folder),
            primaryAction: UIAction { [weak coordinator] _ in
                coordinator?.didPressBulkMoveItems(selectedItems)
            }
        )
        let canMoveSelection = selectedItems.allSatisfy { coordinator._canMoveItem($0) }
        bulkMoveButton.isEnabled = selectedItems.count > 0 && canMoveSelection
        toolbarItems.append(bulkMoveButton)

        toolbarItems.append(.flexibleSpace())
        let bulkDeleteButton = UIBarButtonItem(
            systemItem: .trash,
            primaryAction: UIAction { [weak coordinator] action in
                coordinator?.confirmAndBulkDeleteItems(
                    selectedItems,
                    at: action.presentationSourceItem?.asPopoverAnchor
                )
            }
        )
        bulkDeleteButton.title = LString.actionDelete
        let canDeleteSelection = selectedItems.allSatisfy { coordinator._canDeleteItem($0) }
        bulkDeleteButton.isEnabled = selectedItems.count > 0 && canDeleteSelection
        toolbarItems.append(bulkDeleteButton)

        return toolbarItems
    }
}

extension DatabaseViewerCoordinator {
    internal func _saveUnsavedBulkChanges(onSuccess: (() -> Void)?) {
        guard _hasUnsavedBulkChanges else {
            onSuccess?()
            return
        }
        saveDatabase(_databaseFile) { [weak self] in
            guard let self else { return }
            _hasUnsavedBulkChanges = false
            refresh()
            onSuccess?()
        }
    }

    internal func _deleteItemsConfirmed(_ items: [DatabaseItem]) {
        items.compactMap({ $0 as? Entry }).forEach {
            _database.delete(entry: $0)
        }
        items.compactMap({ $0 as? Group }).forEach {
            _database.delete(group: $0)
        }
        items.forEach {
            $0.touch(.accessed)
        }
        _hasUnsavedBulkChanges = true
    }

    private func didPressDoneBulkEditing() {
        _topGroupViewer?.endBulkEditing(animated: true)
        refresh(animated: true)
        _saveUnsavedBulkChanges(onSuccess: nil)
    }

    private func didPressBulkDownloadFavicons(for selectedItems: [DatabaseItem]) {
        guard let groupViewerVC = _topGroupViewer else {
            assertionFailure()
            return
        }
        groupViewerVC.endBulkEditing(animated: true)
        let entries = selectedItems.compactMap({ $0 as? Entry })
        guard !entries.isEmpty else {
            return
        }
        _downloadFavicons(for: entries, in: groupViewerVC)
    }

    private func didPressBulkMoveItems(_ items: [DatabaseItem]) {
        _topGroupViewer?.endBulkEditing(animated: false)
        _saveUnsavedBulkChanges(onSuccess: { [weak self] in
            self?._showItemRelocator(for: items, mode: .move)
        })
    }

    private func confirmAndBulkDeleteItems(_ items: [DatabaseItem], at popoverAnchor: PopoverAnchor?) {
        let confirmationAlert = UIAlertController(
            title: String.localizedStringWithFormat(LString.itemsSelectedCountTemplate, items.count),
            message: nil,
            preferredStyle: .actionSheet
        )
        let actionTitle = items.count > 1 ? LString.actionDeleteAll : LString.actionDelete
        confirmationAlert.addAction(title: actionTitle, style: .destructive) { [weak self] _ in
            guard let self else { return }
            _topGroupViewer?.endBulkEditing(animated: false)
            _deleteItemsConfirmed(items)
            _saveUnsavedBulkChanges(onSuccess: nil)
        }
        confirmationAlert.addAction(title: LString.actionCancel, style: .cancel, handler: nil)
        if let popoverAnchor {
            confirmationAlert.modalPresentationStyle = .popover
            popoverAnchor.apply(to: confirmationAlert.popoverPresentationController)
        }

        let presenter = _topGroupViewer ?? _presenterForModals
        presenter.present(confirmationAlert, animated: true, completion: nil)
    }
}
