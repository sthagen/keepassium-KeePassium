//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension AutoFillCoordinator {
    internal func _isNeedsOnboarding() -> Bool {
        if FileKeeper.canPossiblyAccessAppSandbox {
            return false
        }

        let validDatabases = FileKeeper.shared
            .getAllReferences(fileType: .database, includeBackup: false)
            .filter { !$0.hasError }
        return validDatabases.isEmpty
    }

    internal func _presentOnboarding() {
        let firstSetupVC = FirstSetupVC.make(delegate: self)
        firstSetupVC.navigationItem.hidesBackButton = true
        _router.present(firstSetupVC, animated: false, completion: nil)
    }

    internal func _showUncheckKeychainMessage() {
        let setupMessageVC = AutoFillSetupMessageVC.instantiateFromStoryboard()
        setupMessageVC.completionHanlder = { [weak self] in
            self?.extensionContext.completeExtensionConfigurationRequest()
        }
        _router.push(setupMessageVC, animated: true, onPop: nil)
    }
}

extension AutoFillCoordinator: FirstSetupDelegate {
    func didPressCancel(in firstSetup: FirstSetupVC) {
        dismissAndQuit()
    }

    func didPressAddExistingDatabase(in firstSetup: FirstSetupVC) {
        watchdog.restart()
        firstSetup.dismiss(animated: true, completion: nil)
        _databasePickerCoordinator.startExternalDatabasePicker(presenter: _router.navigationController)
    }

    func didPressAddRemoteDatabase(in firstSetup: FirstSetupVC) {
        watchdog.restart()
        firstSetup.dismiss(animated: true, completion: nil)
        _databasePickerCoordinator.paywalledStartRemoteDatabasePicker(
            bypassPaywall: false,
            presenter: _router.navigationController
        )
    }

    func didPressSkip(in firstSetup: FirstSetupVC) {
        watchdog.restart()
        firstSetup.dismiss(animated: true, completion: nil)
    }
}
