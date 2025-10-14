//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
#if INTUNE
import MSAL
#endif

extension MainCoordinator {
    @discardableResult
    public func processIncomingURL(_ url: URL, sourceApp: String?, openInPlace: Bool?) -> Bool {
        #if INTUNE
        if url.absoluteString.hasPrefix(MSALOneDriveAuthProvider.redirectURI) {
            let isHandled = MSALPublicClientApplication.handleMSALResponse(
                url,
                sourceApplication: sourceApp)
            Diag.info("Processed MSAL auth callback [isHandled: \(isHandled)]")
            return isHandled
        }
        #endif
        Diag.info("Will process incoming URL [inPlace: \(String(describing: openInPlace)), URL: \(url.redacted)]")
        if let _databaseViewerCoordinator,
           mustCloseDatabaseToImportURL(url)
        {
            _databaseViewerCoordinator.closeDatabase(
                shouldLock: false,
                reason: .appLevelOperation,
                animated: false,
                completion: { [weak self] in
                    self?.handleIncomingURL(url, openInPlace: openInPlace ?? true)
                }
            )
        } else {
            handleIncomingURL(url, openInPlace: openInPlace ?? true)
        }
        return true
    }

    private func mustCloseDatabaseToImportURL(_ url: URL) -> Bool {
        return !(url.isDeepLinkURL || url.isOTPAuthURL)
    }

    private func handleIncomingURL(_ url: URL, openInPlace: Bool) {
        if url.isDeepLinkURL {
            processDeepLink(url)
            return
        }
        if url.isOTPAuthURL {
            _handleIncomingOTPAuthURL(url)
            return
        }

        if _rootSplitVC.isCollapsed {
            _rootSplitVC.show(.primary)
            _primaryRouter.dismissModals(animated: false, completion: { [weak _databasePickerCoordinator] in
                _databasePickerCoordinator?.addDatabaseURL(url)
            })
        } else {
            _databasePickerCoordinator.addDatabaseURL(url)
        }
    }

    private func _handleIncomingOTPAuthURL(_ url: URL) {
        assert(url.isOTPAuthURL)

        guard TOTPGeneratorFactory.isValidURI(url.absoluteString) else {
            Diag.warning("Invalid OTP URL received [url: \(url.redacted)]")
            return
        }

        Diag.info("Valid OTP URL received, storing for import [url: \(url.redacted)]")
        _setIncomingOTPAuthURL(url)
    }

    private func processDeepLink(_ url: URL) {
        assert(url.scheme == AppGroup.appURLScheme)
        switch url {
        case AppGroup.upgradeToPremiumURL:
            showPremiumUpgrade(in: _rootSplitVC)
        case AppGroup.donateURL:
            _showDonationScreen(in: _rootSplitVC)
        default:
            Diag.warning("Unrecognized URL, ignoring [url: \(url.absoluteString)]")
        }
    }

    internal func _setIncomingOTPAuthURL(_ url: URL?) {
        _incomingOTPAuthURL = url
        _databasePickerCoordinator.setHasIncomingOTPAuthURL(_incomingOTPAuthURL != nil)
        _databaseViewerCoordinator?.setIncomingOTPAuthURL(url)
    }
}

extension MainCoordinator: FileKeeperDelegate {
    func shouldResolveImportConflict(
        target: URL,
        handler: @escaping (FileKeeper.ConflictResolution) -> Void
    ) {
        assert(Thread.isMainThread, "FileKeeper called its delegate on background queue, that's illegal")
        let fileName = target.lastPathComponent
        let choiceAlert = UIAlertController(
            title: fileName,
            message: LString.fileAlreadyExists,
            preferredStyle: .alert)
        let actionOverwrite = UIAlertAction(title: LString.actionOverwrite, style: .destructive) { _ in
            handler(.overwrite)
        }
        let actionRename = UIAlertAction(title: LString.actionRename, style: .default) { _ in
            handler(.rename)
        }
        let actionAbort = UIAlertAction(title: LString.actionCancel, style: .cancel) { _ in
            handler(.abort)
        }
        choiceAlert.addAction(actionOverwrite)
        choiceAlert.addAction(actionRename)
        choiceAlert.addAction(actionAbort)

        _presenterForModals.present(choiceAlert, animated: true)
    }
}
