//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    @discardableResult
    internal func _maybeApplyAndSavePendingChanges(recoveryMode: Bool) -> Bool {
        guard _databaseFile.hasPendingOperations() else {
            return false
        }
        do {
            try _databaseFile.applyUnappliedPendingOperations(recoveryMode: recoveryMode)
        } catch {
            Diag.error("Failed to apply pending operations, skipping auto-saving [message: \(error.localizedDescription)]")
            return false
        }
        guard _canEditDatabase else {
            Diag.debug("Read-only file, skipping auto-saving")
            return false
        }
        Diag.info("Will auto-save pending changes")
        saveDatabase(_databaseFile, onSuccess: { [weak self] in
            guard let self,
                  let recoveryGroup = _databaseFile.latestRecoveryGroup
            else { return }
            _pushGroupViewer(for: recoveryGroup, animated: true)
        })
        return true
    }

    internal func _showingProblematicOperationsAlert(
        _ isProblematic: Bool,
        presenter: UIViewController,
        completion: @escaping () -> Void
    ) {
        guard isProblematic else {
            completion()
            return
        }

        let alert = UIAlertController.make(
            title: LString.titleUnsavedChanges,
            message: LString.messageProblematicChangesInfo,
            dismissButtonTitle: LString.actionCancel
        )
        alert.addAction(title: LString.actionContinue, style: .default, preferred: true) { _ in
            completion()
        }
        presenter.present(alert, animated: true)
    }
}
