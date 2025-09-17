//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryCreatorCoordinator {

    func _makeInitialEntryData() {
        guard let rootGroup = _databaseFile.database.root else {
            assertionFailure()
            return
        }
        let username = UserNameHelper.getUserNameSuggestions(from: _databaseFile.database, count: 1).first
        let password = _generateInitialPassword(with: Settings.current.passwordGeneratorConfig)
        let url = _getContextURL(from: _searchContext)
        let title = _makeTitle(from: url)
        _entryData = EntryCreatorEntryData(
            parentGroup: rootGroup,
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

    private func _generateInitialPassword(with config: PasswordGeneratorParams) -> String? {
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
