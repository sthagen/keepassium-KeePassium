//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryCreatorCoordinator {
    func _getDefaultParentGroup() -> Group? {
        let database = _databaseFile.database
        if database.supportsEntriesInRoot {
            return database.root
        } else {
            return database.root?.groups.first(where: { !$0.isDeleted })
        }
    }

    func _makeInitialEntryData() {
        guard let defaultParentGroup = _getDefaultParentGroup() else {
            assertionFailure()
            return
        }
        let username = UserNameHelper.getUserNameSuggestions(from: _databaseFile.database, count: 1).first
        let url = _getContextURL(from: _searchContext)
        let password = _generateSiteSpecificPassword(for: url)
                    ?? _generateAPassword(with: Settings.current.passwordGeneratorConfig)
        let title = _makeTitle(from: url)
        _entryData = EntryCreatorEntryData(
            parentGroup: defaultParentGroup,
            title: title ?? "",
            username: username ?? "",
            password: password ?? "",
            isPasswordProtected: true,
            url: url?.absoluteString ?? "",
            notes: ""
        )
    }

    private func _makeTitle(from url: URL?) -> String? {
        guard let url else { return nil }

        guard let domain = DomainNameHelper.shared.parse(url: url)?.domain else {
            guard let host = url.host(percentEncoded: false) ?? url.host(percentEncoded: true) else {
                return nil
            }
            if let port = url.port {
                return host + ":" + String(port)
            } else {
                return host
            }
        }

        let title = String(domain.prefix(1).localizedUppercase + domain.dropFirst())
        return title
    }

    private func _generateSiteSpecificPassword(for url: URL?) -> String? {
        guard let url,
              let host = url.host(percentEncoded: false) ?? url.host(percentEncoded: true),
              let siteParams = PasswordGeneratorParams.siteSpecific[host]
        else {
            return nil
        }

        let reqs = siteParams.toRequirements()
        do {
            Diag.info("Found site-specific password rules, generating…")
            let password = try PasswordGenerator().generate(with: reqs)
            return password
        } catch {
            Diag.error("Failed to generate password [message: \(error)]")
            return nil
        }
    }

    private func _generateAPassword(with config: PasswordGeneratorParams) -> String? {
        switch config.lastMode {
        case .basic:
            let reqs = config.basicModeConfig.toRequirements()
            return try? PasswordGenerator().generate(with: reqs)
        case .custom:
            let reqs = config.customModeConfig.toRequirements()
            return try? PasswordGenerator().generate(with: reqs)
        case .passphrase:
            let reqs = config.passphraseModeConfig.toRequirements()
            return try? PassphraseGenerator().generate(with: reqs)
        }
    }

    private func _getContextURL(from context: AutoFillSearchContext) -> URL? {
        if let serviceID = context.serviceIdentifiers.first {
            switch serviceID.type {
            case .domain:
                return URL(string: "https://" + serviceID.identifier)
            case .URL:
                return URL(string: serviceID.identifier)
            @unknown default:
                assertionFailure("Unexpected service identifier type: \(serviceID.type)")
                return nil
            }
        }
        if let relyingPartyDomain = context.passkeyRelyingParty {
            return URL(string: "https://" + relyingPartyDomain)
        }
        return nil
    }
}
