//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import AuthenticationServices
import KeePassiumLib

struct AutoFillSearchContext {
    var userQuery: String?
    var serviceIdentifiers: [ASCredentialServiceIdentifier]
    var passkeyRelyingParty: String?

    func getRepresentativeURL(mode: AutoFillContextSavingMode = .hostnameAndPath) -> URL? {
        switch mode {
        case .inactive:
            return nil
        case .hostnameAndPath:
            break
        }

        guard let firstServiceIdentifier = serviceIdentifiers.first else {
            return nil
        }
        switch firstServiceIdentifier.type {
        case .domain:
            return URL(string: "https://\(firstServiceIdentifier.identifier)")
        case .URL:
            guard let url = URL(string: firstServiceIdentifier.identifier),
                  var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else {
                assertionFailure()
                return nil
            }
            urlComponents.fragment = nil
            urlComponents.queryItems = nil
            urlComponents.user = nil
            urlComponents.password = nil
            return urlComponents.url
        @unknown default:
            assertionFailure("Unexpected service identifier type")
            return nil
        }
    }
}
