//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    private var entryViewerCoordinator: EntryViewerCoordinator? {
        childCoordinators
            .compactMap { $0 as? EntryViewerCoordinator }
            .first
    }

    internal func _selectEntry(_ entry: Entry?) {
        _focusOnEntry(entry)
        _showEntry(entry)
    }

    internal func _focusOnEntry(_ entry: Entry?) {
        assert(_topGroupViewer != nil)
        _topGroupViewer?.selectEntry(entry, animated: false)
    }

    internal func _showEntry(_ entry: Entry?) {
        defer {
            UIMenu.rebuildMainMenu()
        }
        _currentEntry = entry
        guard let entry else {
            _splitViewController.setSecondaryRouter(nil)
            _entryViewerRouter = nil
            childCoordinators.removeAll(where: { $0 is EntryViewerCoordinator })
            return
        }

        if let entryViewerCoordinator = self.entryViewerCoordinator {
            entryViewerCoordinator.setEntry(
                entry,
                isHistoryEntry: false,
                canEditEntry: _canEditDatabase && !entry.isDeleted
            )
            guard let _entryViewerRouter else {
                Diag.error("Coordinator without a router, aborting")
                assertionFailure()
                return
            }
            _splitViewController.setSecondaryRouter(_entryViewerRouter)
            return
        }

        let entryViewerRouter = NavigationRouter(RouterNavigationController())
        self._entryViewerRouter = entryViewerRouter
        let entryViewerCoordinator = EntryViewerCoordinator(
            entry: entry,
            databaseFile: _databaseFile,
            isHistoryEntry: false,
            canEditEntry: _canEditDatabase && !entry.isDeleted,
            router: entryViewerRouter,
            progressHost: self
        )
        entryViewerCoordinator.delegate = self
        entryViewerCoordinator.start()
        addChildCoordinator(entryViewerCoordinator, onDismiss: { [weak self] _ in
            self?._entryViewerRouter = nil
        })

        _splitViewController.setSecondaryRouter(entryViewerRouter)
    }

    internal func _showEntryCreator() {
        _primaryRouter.dismissModals(animated: true) { [self] in
            _showEntryEditor(for: nil)
        }
    }

    internal func _showEntryEditor(
        for entryToEdit: Entry?,
        onDismiss: (() -> Void)? = nil
    ) {
        Diag.info("Will edit entry")
        guard let parent = _currentGroup else {
            Diag.warning("Parent group is not definted")
            assertionFailure()
            return
        }

        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let entryFieldEditorCoordinator = EntryFieldEditorCoordinator(
            router: modalRouter,
            databaseFile: _databaseFile,
            parent: parent,
            target: entryToEdit
        )
        entryFieldEditorCoordinator.delegate = self
        entryFieldEditorCoordinator.start()
        modalRouter.dismissAttemptDelegate = entryFieldEditorCoordinator

        _presenterForModals.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(entryFieldEditorCoordinator, onDismiss: { [onDismiss] _ in
            onDismiss?()
        })
    }

    internal func _canPerformAutoType() -> Bool {
        guard let _currentEntry,
              _autoTypeHelper != nil
        else {
            return false
        }
        return !_currentEntry.resolvedUserName.isEmpty || !_currentEntry.resolvedPassword.isEmpty
    }

#if targetEnvironment(macCatalyst)
    internal func _performAutoType(entry: Entry) {
        guard let _autoTypeHelper else {
            assertionFailure("AutoTypeHelper not available")
            return
        }

        let username = entry.getField(EntryField.userName)?.resolvedValue ?? ""
        let password = entry.getField(EntryField.password)?.resolvedValue ?? ""
        _autoTypeHelper.tryPerformAutoType(from: _presenterForModals, username: username, password: password)
    }

    internal func _performAutoType() {
        guard let _currentEntry else {
            return
        }
        _performAutoType(entry: _currentEntry)
    }
#endif

    internal func _canCopyCurrentEntryField(_ fieldName: String) -> Bool {
        guard let value = _currentEntry?.getField(fieldName)?.resolvedValue else {
            return false
        }
        return value.isNotEmpty
    }

    internal func _copyCurrentEntryField(_ fieldName: String) {
        guard let _currentEntry else { return }
        guard let value = _currentEntry.getField(fieldName)?.resolvedValue else {
            assertionFailure("Unexpected field name")
            return
        }
        Clipboard.general.copyWithTimeout(value)
    }
}

extension DatabaseViewerCoordinator {
    internal func _confirmAndDeleteEntry(_ entry: Entry, at popoverAnchor: PopoverAnchor) {
        let alert = UIAlertController.make(
            title: entry.resolvedTitle,
            message: nil,
            dismissButtonTitle: LString.actionCancel
        )
        alert.addAction(title: LString.actionDelete, style: .destructive) { [weak self, weak entry] _ in
            guard let self, let entry else { return }
            _deleteEntryConfirmed(entry)
        }
        alert.modalPresentationStyle = .popover
        popoverAnchor.apply(to: alert.popoverPresentationController)
        let presenter = _topGroupViewer ?? _presenterForModals
        presenter.present(alert, animated: true)
    }

    private func _deleteEntryConfirmed(_ entry: Entry) {
        _database.delete(entry: entry)
        entry.touch(.accessed)
        let isDeletedCurrentEntry = (entry === _currentEntry)
        if isDeletedCurrentEntry {
            _selectEntry(nil)
            _showEntry(nil)
        }
        saveDatabase(_databaseFile)
    }
}

extension DatabaseViewerCoordinator: EntryViewerCoordinatorDelegate {
    func didUpdateEntry(_ entry: Entry, in coordinator: EntryViewerCoordinator) {
        refresh()
    }

    func didRelocateDatabase(_ databaseFile: DatabaseFile, to url: URL) {
        delegate?.didRelocateDatabase(databaseFile, to: url)
    }

    func didPressOpenLinkedDatabase(_ info: LinkedDatabaseInfo, in coordinator: EntryViewerCoordinator) {
        delegate?.didPressSwitchTo(
            databaseRef: info.databaseRef,
            compositeKey: info.compositeKey,
            in: self
        )
    }
}

extension DatabaseViewerCoordinator: EntryFieldEditorCoordinatorDelegate {
    func didUpdateEntry(_ entry: Entry, in coordinator: EntryFieldEditorCoordinator) {
        refresh()
        if _splitViewController.isCollapsed {
            let isNewEntry = coordinator.isCreating
            if isNewEntry {
                Settings.current.entryViewerPage = 0
                _selectEntry(entry)
            } else {
                _focusOnEntry(entry)
            }
        } else {
            _selectEntry(entry)
        }
        StoreReviewSuggester.maybeShowAppReview(
            appVersion: AppInfo.version,
            occasion: .didEditItem,
            presenter: UIApplication.shared.currentActiveScene
        )
    }
}
