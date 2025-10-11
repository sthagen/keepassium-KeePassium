//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension MainCoordinator {
    internal func _maybeShowOnboarding() {
        let files = FileKeeper.shared.getAllReferences(fileType: .database, includeBackup: true)
        guard files.isEmpty else {
            _maybeStartAppPasscodeSetup()
            return
        }

        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let onboardingCoordinator = OnboardingCoordinator(router: modalRouter)
        onboardingCoordinator.delegate = self
        onboardingCoordinator.start()
        addChildCoordinator(onboardingCoordinator, onDismiss: nil)

        _rootSplitVC.present(modalRouter, animated: true, completion: nil)
    }
}

extension MainCoordinator: OnboardingCoordinatorDelegate {
    func didPressCreateDatabase(in coordinator: OnboardingCoordinator) {
        coordinator.dismiss { [weak self] in
            guard let self else { return }
            _databasePickerCoordinator.startDatabaseCreator(presenter: _rootSplitVC)
        }
    }

    func didPressAddExistingDatabase(in coordinator: OnboardingCoordinator) {
        coordinator.dismiss { [weak self] in
            guard let self else { return }
            _databasePickerCoordinator.startExternalDatabasePicker(presenter: _rootSplitVC)
        }
    }

    func didPressConnectToServer(in coordinator: OnboardingCoordinator) {
        Diag.info("Network access permission implied by user action")
        Settings.current.isNetworkAccessAllowed = true
        coordinator.dismiss { [weak self] in
            guard let self else { return }
            _databasePickerCoordinator.startRemoteDatabasePicker(
                mode: .pick(.file),
                presenter: _rootSplitVC
            )
        }
    }
}
