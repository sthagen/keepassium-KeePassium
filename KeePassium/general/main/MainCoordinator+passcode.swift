//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension MainCoordinator {
    internal func _maybeStartAppPasscodeSetup() {
        let isPasscodeSet = (try? Keychain.shared.isAppPasscodeSet()) ?? false
        guard ManagedAppConfig.shared.isRequireAppPasscodeSet,
              !isPasscodeSet
        else {
            return
        }
        _showAppPasscodeSetup()
    }

    private func _showAppPasscodeSetup() {
        let passcodeVC = PasscodeInputVC.instantiateFromStoryboard()
        passcodeVC.mode = .setup
        passcodeVC.isCancelAllowed = false
        passcodeVC.delegate = self
        _presenterForModals.present(passcodeVC, animated: true)
    }
}

extension MainCoordinator: PasscodeInputDelegate {
    func passcodeInput(_ sender: PasscodeInputVC, shouldTryPasscode passcode: String) {
        let isMatch = try? Keychain.shared.isAppPasscodeMatch(passcode)
        if isMatch ?? false {
            passcodeInput(sender, didEnterPasscode: passcode)
        }
    }

    func passcodeInput(_ sender: PasscodeInputVC, didEnterPasscode passcode: String) {
        switch sender.mode {
        case .verification:
            verifyPasscode(passcode, viewController: sender)
        case .setup, .change:
            setupPasscode(passcode, viewController: sender)
        }
    }

    func passcodeInputDidRequestBiometrics(_ sender: PasscodeInputVC) {
        assert(_canUseBiometrics())
        _performBiometricUnlock()
    }

    private func setupPasscode(_ passcode: String, viewController: PasscodeInputVC) {
        Diag.info("Passcode setup successful")
        do {
            try Keychain.shared.setAppPasscode(passcode)
            viewController.dismiss(animated: true)
        } catch {
            Diag.error("Keychain error [message: \(error.localizedDescription)]")
            viewController.showErrorAlert(error, title: LString.titleKeychainError)
        }
    }

    private func verifyPasscode(_ passcode: String, viewController: PasscodeInputVC) {
        do {
            if try Keychain.shared.isAppPasscodeMatch(passcode) {
                HapticFeedback.play(.appUnlocked)
                _watchdog.unlockApp()
                Keychain.shared.prepareBiometricAuth(true)
            } else {
                HapticFeedback.play(.wrongPassword)
                viewController.animateWrongPassccode()
                StoreReviewSuggester.registerEvent(.trouble)
                handleFailedPasscode()
            }
        } catch {
            let alert = UIAlertController.make(
                title: LString.titleKeychainError,
                message: error.localizedDescription)
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    private func handleFailedPasscode() {
        // swiftlint:disable:next trailing_closure
        let isResetting = AppEraser.registerFailedAppPasscodeAttempt(afterReset: {
            exit(0)
        })
        if isResetting {
            return
        }

        if Settings.current.isLockAllDatabasesOnFailedPasscode {
            DatabaseSettingsManager.shared.eraseAllMasterKeys()
            _databaseViewerCoordinator?.closeDatabase(
                shouldLock: true,
                reason: .databaseTimeout,
                animated: false,
                completion: nil
            )
        }
    }
}
