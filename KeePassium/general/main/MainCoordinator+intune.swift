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

#if INTUNE
extension MainCoordinator {
    internal func _setupIntune(waitForIncomingURL: Bool) {
        assert(_policyDelegate == nil && _enrollmentDelegate == nil, "Repeated call to Intune setup")

        _policyDelegate = IntunePolicyDelegateImpl()
        IntuneMAMPolicyManager.instance().delegate = _policyDelegate

        _enrollmentDelegate = IntuneEnrollmentDelegateImpl(
            onEnrollment: { [weak self] enrollmentResult in
                guard let self else { return }
                switch enrollmentResult {
                case .success:
                    Diag.info("Intune enrollment successful")
                    _runAfterStartTasks(waitForIncomingURL: waitForIncomingURL)
                case .cancelledByUser:
                    let message = [
                            LString.Intune.orgNeedsToManage,
                            LString.Intune.personalVersionInAppStore
                    ].joined(separator: "\n\n")
                    Diag.error("Intune enrollment cancelled")
                    showIntuneMessageAndRestartEnrollment(message)
                case .failure(let errorMessage):
                    Diag.error("Intune enrollment failed [message: \(errorMessage)]")
                    showIntuneMessageAndRestartEnrollment(errorMessage)
                }
            },
            onUnenrollment: { [weak self] wasSuccessful in
                self?._startIntuneEnrollment()
            }
        )
        IntuneMAMEnrollmentManager.instance().delegate = _enrollmentDelegate

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_applyIntuneAppConfig),
            name: NSNotification.Name.IntuneMAMAppConfigDidChange,
            object: IntuneMAMAppConfigManager.instance()
        )
    }

    internal func _startIntuneEnrollment() {
        Diag.debug("Starting Intune enrollment")
        let enrollmentManager = IntuneMAMEnrollmentManager.instance()
        enrollmentManager.delegate = _enrollmentDelegate
        enrollmentManager.loginAndEnrollAccount(enrollmentManager.enrolledAccountId())
    }

    private func showIntuneMessageAndRestartEnrollment(_ message: String) {
        let alert = UIAlertController(
            title: "",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(title: LString.actionOK, style: .default) { [weak self] _ in
            self?._startIntuneEnrollment()
        }
        _presenterForModals.present(alert, animated: true)
    }

    @objc internal func _applyIntuneAppConfig() {
        guard let enrolledUserId = IntuneMAMEnrollmentManager.instance().enrolledAccountId() else {
            assertionFailure("There must be an enrolled account by now")
            Diag.warning("No enrolled account found")
            return
        }
        let config = IntuneMAMAppConfigManager.instance().appConfig(forAccountId: enrolledUserId)
        ManagedAppConfig.shared.setIntuneAppConfig(config.fullData)
    }

    internal func _showOrgLicensePaywall() {
        let message = [
                LString.Intune.orgLicenseMissing,
                LString.Intune.hintContactYourAdmin,
        ].joined(separator: "\n\n")
        Diag.error(message)
        let alert = UIAlertController(
            title: "",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(title: LString.actionRetry, style: .default) { [weak self] _ in
            self?._runAfterStartTasks(waitForIncomingURL: false)
        }
        alert.addAction(title: LString.titleDiagnosticLog, style: .default) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self._showDiagnostics(in: self._presenterForModals, onDismiss: { [weak self] in
                    self?._runAfterStartTasks(waitForIncomingURL: false)
                })
            }
        }
        DispatchQueue.main.async { [self] in
            _presenterForModals.present(alert, animated: true)
        }
    }
}
#endif
