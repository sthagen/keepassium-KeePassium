//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabasePickerCoordinator {
    public func paywalledStartExternalDatabasePicker(presenter: UIViewController) {
        guard needsPremiumToAddDatabase() else {
            startExternalDatabasePicker(presenter: presenter)
            return
        }
        performPremiumActionOrOfferUpgrade(for: .canUseMultipleDatabases, in: presenter) {
            [weak self, weak presenter] in
            guard let self, let presenter else { return }
            startExternalDatabasePicker(presenter: presenter)
        }
    }

    public func startExternalDatabasePicker(_ fileRef: URLReference? = nil, presenter: UIViewController) {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: FileType.databaseUTIs,
            asCopy: false)
        picker.delegate = self
        picker.modalPresentationStyle = .pageSheet
        picker.directoryURL = fileRef?.url?.deletingLastPathComponent()
        presenter.present(picker, animated: true, completion: nil)
    }
}

extension DatabasePickerCoordinator: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        warnIfNotADatabase(url, presenter: _filePickerVC) { [weak self] url in
            self?.addDatabaseURL(url)
        }
    }
}

extension DatabasePickerCoordinator {
    public func paywalledStartRemoteDatabasePicker(bypassPaywall: Bool, presenter: UIViewController) {
        guard needsPremiumToAddDatabase() && !bypassPaywall else {
            presenter.ensuringNetworkAccessPermitted { [weak self, weak presenter] in
                guard let self, let presenter else { return }
                startRemoteDatabasePicker(mode: .pick(.file), presenter: presenter)
            }
            return
        }

        performPremiumActionOrOfferUpgrade(for: .canUseMultipleDatabases, in: presenter) {
            [weak self, weak presenter] in
            guard let self, let presenter else { return }
            startRemoteDatabasePicker(mode: .pick(.file), presenter: presenter)
        }
    }

    public func startRemoteDatabasePicker(mode: RemoteConnectionSetupMode, presenter: UIViewController) {
        presenter.ensuringNetworkAccessPermitted { [weak self, weak presenter] in
            guard let self, let presenter else { return }
            startRemoteDatabasePickerNetworkConfirmed(mode: mode, presenter: presenter)
        }
    }

    private func startRemoteDatabasePickerNetworkConfirmed(
        mode: RemoteConnectionSetupMode,
        presenter: UIViewController
    ) {
        guard Settings.current.isNetworkAccessAllowed else {
            Diag.error("Network access denied")
            assertionFailure()
            return
        }

        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let remoteFilePickerCoordinator = RemoteFilePickerCoordinator(
            mode: mode,
            router: modalRouter
        )
        remoteFilePickerCoordinator.delegate = self
        remoteFilePickerCoordinator.start()

        presenter.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(remoteFilePickerCoordinator, onDismiss: { [weak self] _ in
            self?._databaseBeingEdited = nil
        })
    }
}

extension DatabasePickerCoordinator: RemoteFilePickerCoordinatorDelegate {
    func didPickRemoteFile(
        url: URL,
        credential: NetworkCredential,
        in coordinator: RemoteFilePickerCoordinator
    ) {
        CredentialManager.shared.store(credential: credential, for: url)

        if let databaseBeingEdited = _databaseBeingEdited {
            replaceDatabaseURL(oldFileRef: databaseBeingEdited, newURL: url)
            _databaseBeingEdited = nil
        } else {
            addDatabaseURL(url)
        }
    }

    func didSelectSystemFilePicker(in coordinator: RemoteFilePickerCoordinator) {
        paywalledStartExternalDatabasePicker(presenter: _filePickerVC)
    }
}

extension DatabasePickerCoordinator {
    func _didDropFile(_ fileURL: URL, to viewController: FilePickerVC) {
        Diag.debug("Processing dropped database file")

        guard needsPremiumToAddDatabase() else {
            processDroppedDatabase(fileURL, presenter: viewController)
            return
        }

        performPremiumActionOrOfferUpgrade(for: .canUseMultipleDatabases, in: viewController) {
            [weak self] in
            guard let self else { return }
            processDroppedDatabase(fileURL, presenter: viewController)
        }
    }

    private func processDroppedDatabase(_ fileURL: URL, presenter: UIViewController) {
        warnIfNotADatabase(fileURL, presenter: presenter) { [weak self] url in
            self?.addDatabaseURL(url)
        }
    }
}

extension DatabasePickerCoordinator {
    public func needsPremiumToAddDatabase() -> Bool {
        let validDatabases = _fileReferences
            .filter { !$0.needsReinstatement }
            .filter { $0.location != .internalBackup }
        if validDatabases.count == 0 {
            return false
        }
        let isEligible = PremiumManager.shared.isAvailable(feature: .canUseMultipleDatabases)
        return !isEligible
    }

    public func addDatabaseURL(_ url: URL) {
        FileKeeper.shared.addFile(url: url, fileType: .database, mode: .openInPlace) {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fileRef):
                refresh()
                selectDatabase(fileRef, animated: true)
                delegate?.didSelectDatabase(fileRef, cause: .app, in: self)
            case .failure(let fileKeeperError):
                Diag.error("Failed to import database [message: \(fileKeeperError.localizedDescription)]")
                refresh()
            }
        }
    }

    private func replaceDatabaseURL(oldFileRef: URLReference, newURL: URL) {
        let success = FileKeeper.shared.removeExternalReference(oldFileRef, fileType: .database)
        if !success {
            Diag.error("Failed to remove old database reference")
        }

        FileKeeper.shared.addFile(url: newURL, fileType: .database, mode: .openInPlace) {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fileRef):
                refresh()
                selectDatabase(fileRef, animated: true)
                delegate?.didSelectDatabase(fileRef, cause: .app, in: self)
            case .failure(let fileKeeperError):
                Diag.error("Failed to add replacement database [message: \(fileKeeperError.localizedDescription)]")
                refresh()
            }
        }
    }

    internal func warnIfNotADatabase(
        _ url: URL,
        presenter: UIViewController,
        onConfirm confirmationHandler: @escaping (URL) -> Void
    ) {
        if FileType.isDatabaseFile(url: url) {
            confirmationHandler(url)
            return
        }

        DispatchQueue.main.async {
            let fileName = url.lastPathComponent
            let alert = UIAlertController.make(
                title: LString.titleWarning,
                message: String.localizedStringWithFormat(
                    LString.warningNonDatabaseExtension,
                    fileName),
                dismissButtonTitle: LString.actionCancel)
            alert.addAction(title: LString.actionContinue, preferred: true) { _ in
                confirmationHandler(url)
            }
            presenter.present(alert, animated: true, completion: nil)
        }
    }
}
