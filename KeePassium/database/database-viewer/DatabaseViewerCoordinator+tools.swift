//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    internal func _showDiagnostics() {
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let diagnosticsViewerCoordinator = DiagnosticsViewerCoordinator(router: modalRouter)
        diagnosticsViewerCoordinator.start()

        _presenterForModals.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(diagnosticsViewerCoordinator, onDismiss: nil)
    }

    internal func _showAppSettings() {
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let settingsCoordinator = MainSettingsCoordinator(router: modalRouter)
        settingsCoordinator.start()
        addChildCoordinator(settingsCoordinator, onDismiss: nil)
        _presenterForModals.present(modalRouter, animated: true, completion: nil)
    }

    internal func _showTipBox() {
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let tipBoxCoordinator = TipBoxCoordinator(router: modalRouter)
        tipBoxCoordinator.start()
        addChildCoordinator(tipBoxCoordinator, onDismiss: nil)
        _presenterForModals.present(modalRouter, animated: true, completion: nil)
    }
}

extension DatabaseViewerCoordinator: EncryptionSettingsCoordinatorDelegate {
    internal func _showEncryptionSettings(in viewController: UIViewController? = nil) {
        let presenter = viewController ?? _presenterForModals
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let encryptionSettingsCoordinator = EncryptionSettingsCoordinator(
            databaseFile: _databaseFile,
            router: modalRouter
        )
        encryptionSettingsCoordinator.delegate = self
        encryptionSettingsCoordinator.start()
        presenter.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(encryptionSettingsCoordinator, onDismiss: { [weak self] _ in
            self?.refresh()
        })
    }
}

extension DatabaseViewerCoordinator: PasswordAuditCoordinatorDelegate {
    internal func _showPasswordAudit(in viewController: UIViewController? = nil) {
        let presenter = viewController ?? _presenterForModals
        guard ManagedAppConfig.shared.isPasswordAuditAllowed else {
            assertionFailure("This action should have been disabled in UI")
            presenter.showManagedFeatureBlockedNotification()
            return
        }
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let passwordAuditCoordinator = PasswordAuditCoordinator(
            databaseFile: _databaseFile,
            router: modalRouter
        )
        passwordAuditCoordinator.delegate = self
        passwordAuditCoordinator.start()
        presenter.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(passwordAuditCoordinator, onDismiss: { [weak self] _ in
            self?.refresh()
        })
    }

    func didPressEditEntry(
        _ entry: Entry,
        at popoverAnchor: PopoverAnchor,
        in coordinator: PasswordAuditCoordinator,
        onDismiss: @escaping () -> Void
    ) {
        _showEntryEditor(for: entry, onDismiss: onDismiss)
    }
}

extension DatabaseViewerCoordinator {
    internal func _showDatabasePrintDialog() {
        guard ManagedAppConfig.shared.isDatabasePrintAllowed else {
            _presenterForModals.showManagedFeatureBlockedNotification()
            Diag.error("Blocked by organization's policy, cancelling")
            return
        }
        Diag.info("Will print database")
        let databaseFormatter = DatabasePrintFormatter()
        guard let formattedText = databaseFormatter.toAttributedString(
            database: _database,
            title: _databaseFile.visibleFileName)
        else {
            Diag.info("Could not format database for printing, skipping")
            return
        }

        if ProcessInfo.isRunningOnMac {
            showProgressView(title: "", allowCancelling: false, animated: false)
            let indefiniteProgress = ProgressEx()
            indefiniteProgress.totalUnitCount = -1
            indefiniteProgress.status = LString.databaseStatusPreparingPrintPreview
            updateProgressView(with: indefiniteProgress)
        }

        let printFormatter = UISimpleTextPrintFormatter(attributedText: formattedText)
        printFormatter.perPageContentInsets = UIEdgeInsets(
            top: 72,
            left: 72,
            bottom: 72,
            right: 72
        )

        let printController = UIPrintInteractionController.shared
        printController.printFormatter = printFormatter
        printController.present(animated: true, completionHandler: { [weak self] _, _, _ in
            printController.printFormatter = nil
            if ProcessInfo.isRunningOnMac {
                self?.hideProgressView(animated: false)
            }
            Diag.debug("Print dialog closed")
        })
        Diag.debug("Preparing print preview")
    }

}
