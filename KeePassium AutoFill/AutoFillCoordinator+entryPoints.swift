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
    public func startConfigurationUI() {
        log.trace("Starting configuration UI")
        _isInDeviceAutoFillSettings = true
        start()
    }

    public func startUI(forServices serviceIdentifiers: [ASCredentialServiceIdentifier], mode: AutoFillMode) {
        self._serviceIdentifiers = serviceIdentifiers
        self._autoFillMode = mode
        self._passkeyRelyingParty = nil
        self._passkeyClientDataHash = nil
        start()
    }

    public func startPasskeyRegistrationUI(_ request: ASPasskeyCredentialRequest) {
        log.trace("Starting passkey registration UI")
        self._autoFillMode = .passkeyRegistration
        let identity = request.credentialIdentity as! ASPasskeyCredentialIdentity
        self._passkeyRelyingParty = identity.relyingPartyIdentifier
        self._passkeyClientDataHash = request.clientDataHash
        self._passkeyRegistrationParams = PasskeyRegistrationParams(
            identity: identity,
            userVerificationPreference: request.userVerificationPreference,
            clientDataHash: request.clientDataHash,
            supportedAlgorithms: request.supportedAlgorithms)
        start()
    }

    public func startPasskeyAssertionUI(
        allowPasswords: Bool,
        clientDataHash: Data,
        relyingParty: String,
        forServices serviceIdentifiers: [ASCredentialServiceIdentifier]
    ) {
        log.trace("Starting passkey assertion UI")
        self._serviceIdentifiers = serviceIdentifiers
        self._autoFillMode = .passkeyAssertion(allowPasswords)
        self._passkeyClientDataHash = clientDataHash
        self._passkeyRelyingParty = relyingParty
        start()
    }

    public func startUI(forIdentity credentialIdentity: ASCredentialIdentity, mode: AutoFillMode) {
        log.trace("Starting UI to return \(mode.debugDescription, privacy: .public)")
        self._serviceIdentifiers = [credentialIdentity.serviceIdentifier]
        if let recordIdentifier = credentialIdentity.recordIdentifier,
           let record = QuickTypeAutoFillRecord.parse(recordIdentifier)
        {
            _quickTypeRequiredRecord = record
        }
        self._passkeyRelyingParty = (credentialIdentity as? ASPasskeyCredentialIdentity)?.relyingPartyIdentifier
        self._autoFillMode = mode
        start()
    }

    public func providePasskeyWithoutUI(
        forIdentity credentialIdentity: ASPasskeyCredentialIdentity,
        clientDataHash: Data
    ) {
        self._passkeyClientDataHash = clientDataHash
        self._passkeyRelyingParty = credentialIdentity.relyingPartyIdentifier
        provideWithoutUI(forIdentity: credentialIdentity, mode: .passkeyAssertion(false))
    }

    public func provideWithoutUI(forIdentity credentialIdentity: ASCredentialIdentity, mode: AutoFillMode) {
        initServices()
        log.trace("Will provide \(mode.debugDescription, privacy: .public) without UI")
        assert(!hasUI, "This should run in pre-UI mode only")
        Diag.debug("Identity: \(credentialIdentity.description)")

        guard let recordIdentifier = credentialIdentity.recordIdentifier,
              let record = QuickTypeAutoFillRecord.parse(recordIdentifier)
        else {
            log.warning("Failed to parse credential store record, switching to UI")
            _cancelRequest(.userInteractionRequired)
            return
        }
        _quickTypeRequiredRecord = record
        self._autoFillMode = mode

        var dbStatus = DatabaseFile.Status([.readOnly, .useStreams])
        guard let dbRef = _findDatabase(for: record) else {
            log.warning("Failed to find the record, switching to UI")
            QuickTypeAutoFillStorage.removeAll()
            _cancelRequest(.userInteractionRequired)
            return
        }

        var fallbackDBRef: URLReference?
        if !(dbRef.location.isInternal || dbRef.fileProvider == FileProvider.localStorage) {
            fallbackDBRef = DatabaseManager.getFallbackFile(for: dbRef)
        }
        if fallbackDBRef != nil {
            log.info("Found fallback file, using it")
            dbStatus.insert(.localFallback)
        }

        let databaseSettingsManager = DatabaseSettingsManager.shared
        guard let dbSettings = databaseSettingsManager.getSettings(for: dbRef),
              let masterKey = dbSettings.masterKey
        else {
            log.warning("Failed to auto-open the DB, switching to UI")
            _cancelRequest(.userInteractionRequired)
            return
        }
        log.debug("Got stored master key for \(dbRef.visibleFileName, privacy: .private)")

        let timeoutDuration = databaseSettingsManager.getFallbackTimeout(dbRef, forAutoFill: true)

        assert(_quickTypeDatabaseLoader == nil)
        _quickTypeDatabaseLoader = DatabaseLoader(
            originalDBRef: dbRef,
            actualDBRef: fallbackDBRef ?? dbRef,
            compositeKey: masterKey,
            status: dbStatus,
            timeout: Timeout(duration: timeoutDuration),
            delegate: self
        )
        log.trace("Will load database")
        _quickTypeDatabaseLoader!.load()
    }
}
