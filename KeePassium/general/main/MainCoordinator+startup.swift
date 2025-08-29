//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
#if INTUNE
import IntuneMAMSwift
import MSAL
#endif

extension MainCoordinator {
    func start(waitForIncomingURL: Bool, proposeReset: Bool) {
        Diag.info(AppInfo.description)
        guard !proposeReset else {
            showAppResetPrompt()
            return
        }
        PremiumManager.shared.startObservingTransactions()

        FileKeeper.shared.delegate = self

        _watchdog.didBecomeActive()
        StoreReviewSuggester.registerEvent(.sessionStart)

        assert(_databasePickerCoordinator == nil)
        _databasePickerCoordinator = DatabasePickerCoordinator(router: _primaryRouter, mode: .full)
        _databasePickerCoordinator.delegate = self
        _databasePickerCoordinator.start()
        addChildCoordinator(_databasePickerCoordinator, onDismiss: nil)


        #if INTUNE
        _setupIntune(waitForIncomingURL: waitForIncomingURL)
        guard let currentUser = IntuneMAMEnrollmentManager.instance().enrolledAccountId(),
              !currentUser.isEmpty
        else {
            Diag.debug("Intune account missing, starting enrollment")
            _startIntuneEnrollment()
            return
        }
        Diag.info("Intune account is enrolled")
        #endif

        _runAfterStartTasks(waitForIncomingURL: waitForIncomingURL)
    }

    private func showAppResetPrompt() {
        Diag.info("Proposing app reset")
        let alert = UIAlertController(
            title: AppInfo.name,
            message: LString.confirmAppReset,
            preferredStyle: .alert
        )
        alert.addAction(title: LString.actionResetApp, style: .destructive, preferred: false) {
            [unowned self] _ in
            AppEraser.resetApp { [unowned self] in
                start(waitForIncomingURL: false, proposeReset: false)
            }
        }
        alert.addAction(title: LString.actionCancel, style: .cancel) { [weak self] _ in
            self?.start(waitForIncomingURL: false, proposeReset: false)
        }
        _presenterForModals.present(alert, animated: true)
    }

    internal func _runAfterStartTasks(waitForIncomingURL: Bool) {
        #if INTUNE
        _applyIntuneAppConfig()

        guard LicenseManager.shared.hasActiveBusinessLicense() else {
            _showOrgLicensePaywall()
            return
        }
        #endif

        if Settings.current.isFirstLaunch {
            ensureAppDocumentsVisible()
        }

        if waitForIncomingURL {
            Diag.info("Skipping other tasks, waiting for incoming URL")
            return
        }

        DispatchQueue.main.async { [self] in
            if !maybeOpenInitialDatabase() {
                _maybeShowOnboarding()
            }
        }
    }

    private func ensureAppDocumentsVisible() {
        if ProcessInfo.isRunningOnMac { return }
        guard FileProvider.localStorage.isAllowed else { return }

        do {
            try FileKeeper.shared.createPlaceholderInDocumentsDir()
            Diag.info("Made app folder visible in Files app (via placeholder file)")
        } catch {
            Diag.warning("Failed to create placeholder file in app folder: \(error)")
        }
    }

    private func maybeOpenInitialDatabase() -> Bool {
        if Settings.current.isAutoUnlockStartupDatabase,
           let startDatabaseRef = Settings.current.startupDatabase,
           _databasePickerCoordinator.isKnownDatabase(startDatabaseRef)
        {
            if startDatabaseRef.hasError || startDatabaseRef.needsReinstatement {
                _setDatabase(startDatabaseRef, andThen: .doNothing)
            } else {
                _setDatabase(startDatabaseRef, andThen: .unlock)
            }
            return true
        }
        if _rootSplitVC.isCollapsed {
            return false
        }
        let defaultDB = _databasePickerCoordinator.getFirstListedDatabase()
        _setDatabase(defaultDB, andThen: .focus)
        return false
    }
}
