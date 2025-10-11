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
extension AutoFillCoordinator {

    private func getPresenterForModals() -> UIViewController {
        return router.navigationController
    }

    private func setupIntune() {
        assert(policyDelegate == nil && enrollmentDelegate == nil, "Repeated call to Intune setup")

        policyDelegate = IntunePolicyDelegateImpl()
        IntuneMAMPolicyManager.instance().delegate = policyDelegate

        enrollmentDelegate = IntuneEnrollmentDelegateImpl(
            onEnrollment: { [weak self] enrollmentResult in
                guard let self else { return }
                switch enrollmentResult {
                case .success:
                    self.runAfterStartTasks()
                case .cancelledByUser:
                    let message = [
                            LString.Intune.orgNeedsToManage,
                            LString.Intune.personalVersionInAppStore,
                    ].joined(separator: "\n\n")
                    self.showIntuneMessageAndRestartEnrollment(message)
                case .failure(let errorMessage):
                    self.showIntuneMessageAndRestartEnrollment(errorMessage)
                }
            },
            onUnenrollment: { [weak self] wasSuccessful in
                self?.startIntuneEnrollment()
            }
        )
        IntuneMAMEnrollmentManager.instance().delegate = enrollmentDelegate

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applyIntuneAppConfig),
            name: NSNotification.Name.IntuneMAMAppConfigDidChange,
            object: IntuneMAMAppConfigManager.instance()
        )
    }

    private func startIntuneEnrollment() {
        let enrollmentManager = IntuneMAMEnrollmentManager.instance()
        enrollmentManager.delegate = enrollmentDelegate
        enrollmentManager.loginAndEnrollAccount(enrollmentManager.enrolledAccount())
    }

    private func showIntuneMessageAndRestartEnrollment(_ message: String) {
        let alert = UIAlertController(
            title: "",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(title: LString.actionOK, style: .default) { [weak self] _ in
            self?.startIntuneEnrollment()
        }
        getPresenterForModals().present(alert, animated: true)
    }

    @objc private func applyIntuneAppConfig() {
        guard let enrolledUser = IntuneMAMEnrollmentManager.instance().enrolledAccount() else {
            assertionFailure("There must be an enrolled account by now")
            Diag.warning("No enrolled account found")
            return
        }
        let config = IntuneMAMAppConfigManager.instance().appConfig(forIdentity: enrolledUser)
        ManagedAppConfig.shared.setIntuneAppConfig(config.fullData)
    }

    private func showOrgLicensePaywall() {
        let message = [
                LString.Intune.orgLicenseMissing,
                LString.Intune.hintContactYourAdmin,
        ].joined(separator: "\n\n")
        let alert = UIAlertController(
            title: AppInfo.name,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(title: LString.actionRetry, style: .default) { [weak self] _ in
            self?.runAfterStartTasks()
        }
        DispatchQueue.main.async {
            self.getPresenterForModals().present(alert, animated: true)
        }
    }
}
#endif
