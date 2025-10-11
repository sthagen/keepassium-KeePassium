//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import AuthenticationServices
import KeePassiumLib

extension AutoFillCoordinator {
    internal func _cancelRequest(_ code: ASExtensionError.Code) {
        log.info("Cancelling the request with code \(code)")
        extensionContext.cancelRequest(
            withError: NSError(
                domain: ASExtensionErrorDomain,
                code: code.rawValue
            )
        )
        cleanup()
    }

    internal func _returnEntry(
        _ entry: Entry,
        from databaseFile: DatabaseFile,
        shouldSave: Bool,
        keepClipboardIntact: Bool
    ) {
        RecentAutoFillEntryTracker.shared.recordRecentEntry(entry, from: databaseFile)

        switch _autoFillMode {
        case .credentials:
            returnCredentials(
                from: entry,
                databaseFile: databaseFile,
                shouldSave: shouldSave,
                keepClipboardIntact: keepClipboardIntact
            )
        case .oneTimeCode:
            if #available(iOS 18, *) {
                returnOneTimeCode(
                    from: entry,
                    databaseFile: databaseFile,
                    shouldSave: shouldSave
                )
            } else {
                log.error("Tried to return .oneTimeCode before iOS 18, cancelling")
                assertionFailure()
                _cancelRequest(.failed)
            }
        case .passkeyAssertion(let allowPasswords):
            let passkeyReturned = maybeReturnPasskeyAssertion(
                from: entry,
                databaseFile: databaseFile,
                shouldSave: shouldSave
            )
            guard passkeyReturned || allowPasswords else {
                _cancelRequest(.credentialIdentityNotFound)
                return
            }
            returnCredentials(
                from: entry,
                databaseFile: databaseFile,
                shouldSave: shouldSave,
                keepClipboardIntact: keepClipboardIntact
            )
        default:
            let mode = _autoFillMode?.debugDescription ?? "nil"
            log.error("Unexpected AutoFillMode value `\(mode, privacy: .public)`, cancelling")
            assertionFailure()
            _cancelRequest(.failed)
        }
    }

    private func returnCredentials(
        from entry: Entry,
        databaseFile: DatabaseFile,
        shouldSave: Bool,
        keepClipboardIntact: Bool
    ) {
        log.trace("Will return credentials")
        watchdog.restart()

        if let value = getValueForClipboard(for: entry),
           !keepClipboardIntact
        {
            guard hasUI else {
                log.info("Quick entry has OTP, switching to UI to copy it to clipboard")
                _cancelRequest(.userInteractionRequired)
                return
            }
            Clipboard.general.copyWithTimeout(value)
        }

        let passwordCredential = ASPasswordCredential(
            user: entry.resolvedUserName,
            password: entry.resolvedPassword)
        extensionContext.completeRequest(
            withSelectedCredential: passwordCredential,
            completionHandler: { [self] expired in
                guard !expired else { return }
                log.info("Did return credentials (exp: \(expired))")
                if shouldSave {
                    _saveDatabaseWithoutUI(databaseFile)
                }
            }
        )
        if hasUI {
            HapticFeedback.play(.credentialsPasted)
        }
        Settings.current.isAutoFillFinishedOK = true
        cleanup()
    }

    @available(iOS 18.0, *)
    private func returnOneTimeCode(from entry: Entry, databaseFile: DatabaseFile, shouldSave: Bool) {
        log.trace("Will return one time code")
        watchdog.restart()

        guard let totpGenerator = entry.totpGenerator() else {
            log.error("Tried to return one time code from entry with no TOTP, cancelling")
            _cancelRequest(.credentialIdentityNotFound)
            return
        }

        let otp = ASOneTimeCodeCredential(code: totpGenerator.generate())
        extensionContext.completeOneTimeCodeRequest(
            using: otp,
            completionHandler: { [self] expired in
                guard !expired else { return }
                log.info("Did return OTP (exp: \(expired))")
                if shouldSave {
                    _saveDatabaseWithoutUI(databaseFile)
                }
            }
        )

        if hasUI {
            HapticFeedback.play(.credentialsPasted)
        }
        Settings.current.isAutoFillFinishedOK = true
        cleanup()
    }

    @available(iOS 18, *)
    internal func _returnText(
        _ text: String,
        from entry: Entry,
        databaseFile: DatabaseFile,
        shouldSave: Bool
    ) {
        log.trace("Will return text")
        RecentAutoFillEntryTracker.shared.recordRecentEntry(entry, from: databaseFile)

        watchdog.restart()
#if targetEnvironment(macCatalyst)
        // swiftlint:disable:next line_length
        let alert = UIAlertController.make(title: nil, message: "This feature is broken in macOS Sequoia.\n\nInstead, use the 'key' button in the password field.")
        _router.present(alert, animated: true, completion: nil)
#else
        extensionContext.completeRequest(
            withTextToInsert: text,
            completionHandler: { [self] expired in
                guard !expired else { return }
                log.info("Did return text (exp: \(expired))")
                if shouldSave {
                    _saveDatabaseWithoutUI(databaseFile)
                }
            }
        )
        if hasUI {
            HapticFeedback.play(.credentialsPasted)
        }
#endif
        Settings.current.isAutoFillFinishedOK = true
        cleanup()
    }

    internal func _returnPasskeyRegistration(
        passkey: NewPasskey,
        in entry: Entry?,
        andSave databaseFile: DatabaseFile
    ) {
        log.trace("Will return registered passkey")
        if let entry {
            RecentAutoFillEntryTracker.shared.recordRecentEntry(entry, from: databaseFile)
        }

        watchdog.restart()
        guard let clientDataHash = _passkeyClientDataHash else {
            log.error("Passkey request parameters unexpectedly missing, cancelling")
            assertionFailure()
            _cancelRequest(.failed)
            return
        }

        let passkeyCredential = passkey.makeRegistrationCredential(clientDataHash: clientDataHash)
        extensionContext.completeRegistrationRequest(
            using: passkeyCredential,
            completionHandler: { [self] expired in
                guard !expired else { return }
                log.info("Did return passkey (exp: \(expired))")
                _saveDatabaseWithoutUI(databaseFile)
            }
        )

        if hasUI {
            HapticFeedback.play(.credentialsPasted)
        }
        Settings.current.isAutoFillFinishedOK = true
        cleanup()
    }

    private func maybeReturnPasskeyAssertion(
        from entry: Entry,
        databaseFile: DatabaseFile,
        shouldSave: Bool
    ) -> Bool {
        guard let clientDataHash = _passkeyClientDataHash else {
            log.error("Passkey request parameters missing")
            return false
        }
        guard let passkey = Passkey.make(from: entry) else {
            log.error("Selected entry does not have passkeys")
            return false
        }
        returnPasskeyAssertion(
            passkey: passkey,
            clientDataHash: clientDataHash,
            databaseFile: databaseFile,
            shouldSave: shouldSave
        )
        return true
    }

    private func returnPasskeyAssertion(
        passkey: Passkey,
        clientDataHash: Data,
        databaseFile: DatabaseFile,
        shouldSave: Bool
    ) {
        log.trace("Will return passkey")
        watchdog.restart()

        guard let passkeyCredential =
                passkey.makeAssertionCredential(clientDataHash: clientDataHash)
        else {
            log.error("Failed to make passkey credential, cancelling")
            assertionFailure()
            _cancelRequest(.failed)
            return
        }
        extensionContext.completeAssertionRequest(
            using: passkeyCredential,
            completionHandler: { [self] expired in
                guard !expired else { return }
                log.info("Did return passkey (exp: \(expired))")
                if shouldSave {
                    _saveDatabaseWithoutUI(databaseFile)
                }
            }
        )

        if hasUI {
            HapticFeedback.play(.credentialsPasted)
        }
        Settings.current.isAutoFillFinishedOK = true
        cleanup()
    }
}

extension AutoFillCoordinator {
    private func getValueForClipboard(for entry: Entry) -> String? {
        guard Settings.current.isCopyTOTPOnAutoFill else {
            return nil
        }
        guard let totpGenerator = entry.totpGenerator() else {
            return nil
        }
        log.info("Auto-copying TOTP to clipboard.")
        return totpGenerator.generate()
    }
}
