//  KeePassium Password Manager
//  Copyright © 2018-2023 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

public struct OneDriveAuthConfig {
    public let clientID = OneDriveAPI.clientID
    public let redirectURI: String
    public let scopes: [String]

    public init(redirectURI: String, scopes: [String]) {
        self.redirectURI = redirectURI
        self.scopes = scopes
    }
}
