//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension AutoFillCoordinator {
    internal func _showEntryFinder(
        _ fileRef: URLReference,
        databaseFile: DatabaseFile,
        warnings: DatabaseLoadingWarnings
    ) {
        log.trace("Displaying database viewer")
        let coordinator = EntryFinderCoordinator(
            router: _router,
            databaseFile: databaseFile,
            loadingWarnings: warnings,
            serviceIdentifiers: _serviceIdentifiers,
            passkeyRelyingParty: _passkeyRelyingParty,
            passkeyRegistrationParams: _passkeyRegistrationParams,
            autoFillMode: _autoFillMode
        )
        coordinator.delegate = self

        coordinator.start()
        addChildCoordinator(coordinator, onDismiss: { [weak self] _ in
            self?._entryFinderCoordinator = nil
        })
        self._entryFinderCoordinator = coordinator
    }
}

extension AutoFillCoordinator: EntryFinderCoordinatorDelegate {
    func didLeaveDatabase(in coordinator: EntryFinderCoordinator) {
    }

    func didSelectEntry(
        _ entry: Entry,
        from databaseFile: DatabaseFile,
        clipboardIsBusy: Bool,
        in coordinator: EntryFinderCoordinator
    ) {
        log.trace("didSelectEntry, clipboardIsBusy: \(String(describing: clipboardIsBusy))")
        _returnEntry(entry, from: databaseFile, keepClipboardIntact: clipboardIsBusy)
    }

    @available(iOS 18.0, *)
    func didSelectText(
        _ text: String,
        from entry: Entry,
        databaseFile: DatabaseFile,
        in coordinator: EntryFinderCoordinator
    ) {
        _returnText(text, from: entry, databaseFile: databaseFile)
    }

    func didPressCreatePasskey(
        with params: PasskeyRegistrationParams,
        target entry: Entry?,
        databaseFile: DatabaseFile,
        presenter: UIViewController,
        in coordinator: EntryFinderCoordinator
    ) {
        _startPasskeyRegistration(
            with: params,
            target: entry,
            in: databaseFile,
            presenter: presenter
        )
    }

    func didPressReinstateDatabase(_ fileRef: URLReference, in coordinator: EntryFinderCoordinator) {
        coordinator.stop(animated: true) { [weak self] in
            self?._reinstateDatabase(fileRef)
        }
    }
}

extension AutoFillCoordinator {
    private func _startPasskeyRegistration(
        with params: PasskeyRegistrationParams,
        target entry: Entry?,
        in databaseFile: DatabaseFile,
        presenter: UIViewController
    ) {
        let presenter = _router.navigationController
        guard let db2 = databaseFile.database as? Database2,
              let rootGroup = db2.root as? Group2
        else {
            Diag.error("Tried to register passkey in non-KDBX database, cancelling")
            presenter.showErrorAlert(LString.titleDatabaseFormatDoesNotSupportPasskeys)
            return
        }

        let passkey: NewPasskey
        do {
            passkey = try NewPasskey.make(with: params)
        } catch {
            log.error("Failed to create passkey. Reason: \(error.localizedDescription, privacy: .public)")
            presenter.showErrorAlert(error.localizedDescription)
            return
        }

        guard let targetEntry = entry as? Entry2 else {
            Diag.debug("Creating a new passkey entry")
            let createOps = DatabaseOperation.createPasskeyEntry(with: passkey, in: rootGroup)
            _finishPasskeyRegistration(
                passkey,
                operations: createOps,
                entry: nil,
                in: databaseFile,
                presenter: presenter
            )
            return
        }

        let editOp = DatabaseOperation.applyPasskey(passkey, to: targetEntry.uuid)
        guard let _ = Passkey.make(from: targetEntry) else {
            Diag.debug("Adding passkey to existing entry")
            _finishPasskeyRegistration(
                passkey,
                operations: [editOp],
                entry: targetEntry,
                in: databaseFile,
                presenter: presenter
            )
            return
        }

        let overwriteConfirmationAlert = UIAlertController.make(
            title: LString.fieldPasskey,
            message: LString.titleConfirmReplacingExistingPasskey,
            dismissButtonTitle: LString.actionCancel)
        overwriteConfirmationAlert.addAction(
            title: LString.actionReplace,
            style: .destructive,
            preferred: false,
            handler: { [weak self, weak targetEntry, weak databaseFile, weak presenter] _ in
                guard let self, let targetEntry, let databaseFile, let presenter else { return }
                Diag.debug("Replacing passkey in existing entry")
                _finishPasskeyRegistration(
                    passkey,
                    operations: [editOp],
                    entry: targetEntry,
                    in: databaseFile,
                    presenter: presenter
                )
            }
        )
        presenter.present(overwriteConfirmationAlert, animated: true)
    }

    private func _finishPasskeyRegistration(
        _ passkey: NewPasskey,
        operations: [DatabaseOperation],
        entry: Entry?,
        in databaseFile: DatabaseFile,
        presenter: UIViewController
    ) {
        do {
            try databaseFile.addPendingOperations(operations, apply: true)
        } catch {
            presenter.showErrorAlert(error)
            return
        }

        _returnPasskeyRegistration(passkey: passkey, in: entry, andSave: databaseFile)
    }
}
