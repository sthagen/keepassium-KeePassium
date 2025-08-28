//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension MainCoordinator {
    internal func _setupShakeGestureObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShakeGesture),
            name: UIDevice.deviceDidShakeNotification,
            object: nil)
    }

    @objc private func handleShakeGesture() {
        Diag.debug("Device shaken")
        HapticFeedback.play(.deviceShaken)

        let action = Settings.current.shakeGestureAction
        switch action {
        case .nothing:
            break
        case .lockAllDatabases:
            maybeConfirmShakeAction(action) { [weak self] in
                DatabaseSettingsManager.shared.eraseAllMasterKeys()
                self?._lockDatabase()
            }
        case .lockApp:
            guard Settings.current.isAppLockEnabled else {
                Diag.debug("Nothing to lock, ignoring")
                return
            }
            maybeConfirmShakeAction(action) { [weak self] in
                self?._showAppLockScreen()
            }
        case .quitApp:
            maybeConfirmShakeAction(action) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(-1)
                }
            }
        }
    }

    private func maybeConfirmShakeAction(
        _ action: Settings.ShakeGestureAction,
        confirmed: @escaping () -> Void
    ) {
        guard Settings.current.isConfirmShakeGestureAction && !isAppLockVisible else {
            confirmed()
            return
        }

        let alert = UIAlertController
            .make(title: action.shortTitle, message: nil, dismissButtonTitle: LString.actionCancel)
            .addAction(title: LString.actionContinue, style: .default) { _ in
                confirmed()
            }
        Diag.debug("Presenting shake gesture confirmation")
        _presenterForModals.present(alert, animated: true)
    }
}
