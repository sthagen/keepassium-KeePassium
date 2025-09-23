//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
import LocalAuthentication

extension AutoFillCoordinator: WatchdogDelegate {
    var isAppCoverVisible: Bool {
        return false
    }

    func showAppCover(_ sender: Watchdog) {
    }

    func hideAppCover(_ sender: Watchdog) {
    }

    var isAppLockVisible: Bool {
        return _isBiometricAuthShown || _isPasscodeInputShown
    }

    func showAppLock(_ sender: Watchdog) {
        if isAppLockVisible || _isInDeviceAutoFillSettings {
            return
        }
        let shouldUseBiometrics = canUseBiometrics()

        let passcodeInputVC = PasscodeInputVC.instantiateFromStoryboard()
        passcodeInputVC.delegate = self
        passcodeInputVC.mode = .verification
        passcodeInputVC.isCancelAllowed = true
        passcodeInputVC.isBiometricsAllowed = shouldUseBiometrics
        passcodeInputVC.modalTransitionStyle = .crossDissolve

        passcodeInputVC.shouldActivateKeyboard = !shouldUseBiometrics

        rootController.swapChildViewControllers(
            from: _router.navigationController,
            to: passcodeInputVC,
            options: .transitionCrossDissolve)
        _router.dismissModals(animated: false, completion: nil)
        passcodeInputVC.shouldActivateKeyboard = false
        maybeShowBiometricAuth()
        passcodeInputVC.shouldActivateKeyboard = !_isBiometricAuthShown
        self._passcodeInputController = passcodeInputVC
        _isPasscodeInputShown = true
    }

    func hideAppLock(_ sender: Watchdog) {
        dismissPasscodeAndContinue()
    }

    func mustCloseDatabase(_ sender: Watchdog, animate: Bool) {
        if Settings.current.isLockDatabasesOnTimeout {
            _entryFinderCoordinator?.lockDatabase()
        } else {
            _entryFinderCoordinator?.stop(animated: animate, completion: nil)
        }
    }

    private func dismissPasscodeAndContinue() {
        if let _passcodeInputController {
            rootController.swapChildViewControllers(
                from: _passcodeInputController,
                to: _router.navigationController,
                options: .transitionCrossDissolve,
                completion: { [weak self] _ in
                    guard let self else { return }
                    if _isNeedsOnboarding() {
                        _presentOnboarding()
                    }
                }
            )
            self._passcodeInputController = nil
        } else {
            assertionFailure()
        }

        _isPasscodeInputShown = false
        watchdog.restart()
    }

    private func canUseBiometrics() -> Bool {
        return hasUI
            && Settings.current.isBiometricAppLockEnabled
            && LAContext.isBiometricsAvailable()
            && Keychain.shared.isBiometricAuthPrepared()
    }

    private func maybeShowBiometricAuth() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?._maybeShowBiometricAuth()
        }
    }

    private func _maybeShowBiometricAuth() {
        guard canUseBiometrics() else {
            _isBiometricAuthShown = false
            return
        }

        let timeSinceLastSuccess = abs(_lastSuccessfulBiometricAuthTime.timeIntervalSinceNow)
        if timeSinceLastSuccess < LAContext.biometricAuthReuseDuration {
            print("Skipping repeated biometric prompt")
            watchdog.unlockApp()
        }

        Diag.debug("Biometric auth: showing request")
        _lastSuccessfulBiometricAuthTime = .distantPast
        Keychain.shared.performBiometricAuth { [weak self] success in
            guard let self else { return }
            BiometricsHelper.biometricPromptLastSeenTime = Date.now
            _isBiometricAuthShown = false
            if success {
                Diag.info("Biometric auth successful")
                _lastSuccessfulBiometricAuthTime = .now
                watchdog.unlockApp()
            } else {
                Diag.warning("Biometric auth failed")
                _lastSuccessfulBiometricAuthTime = .distantPast
                _passcodeInputController?.showKeyboard()
            }
        }
        _isBiometricAuthShown = true
    }
}

extension AutoFillCoordinator: PasscodeInputDelegate {
    func passcodeInputDidCancel(_ sender: PasscodeInputVC) {
        dismissAndQuit()
    }

    func passcodeInput(_ sender: PasscodeInputVC, shouldTryPasscode passcode: String) {
        let isMatch = try? Keychain.shared.isAppPasscodeMatch(passcode)
        if isMatch ?? false {
            passcodeInput(sender, didEnterPasscode: passcode)
        }
    }

    func passcodeInputDidRequestBiometrics(_ sender: PasscodeInputVC) {
        maybeShowBiometricAuth()
    }

    func passcodeInput(_ sender: PasscodeInputVC, didEnterPasscode passcode: String) {
        do {
            if try Keychain.shared.isAppPasscodeMatch(passcode) {
                HapticFeedback.play(.appUnlocked)
                Keychain.shared.prepareBiometricAuth(true)
                watchdog.unlockApp()
            } else {
                HapticFeedback.play(.wrongPassword)
                sender.animateWrongPassccode()
                StoreReviewSuggester.registerEvent(.trouble)
                handleFailedPasscode()
            }
        } catch {
            Diag.error(error.localizedDescription)
            sender.showErrorAlert(error, title: LString.titleKeychainError)
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
            _entryFinderCoordinator?.lockDatabase()
        }
    }
}
