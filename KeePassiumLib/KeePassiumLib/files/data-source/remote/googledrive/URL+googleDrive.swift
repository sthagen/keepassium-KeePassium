//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension URL {
    var isGoogleDriveFileURL: Bool {
        return self.scheme == GoogleDriveURLHelper.prefixedScheme
    }

    public var isGoogleDriveAppFolderScopedURL: Bool {
        return isGoogleDriveFileURL
            && GoogleDriveURLHelper.getScope(from: self) == .appFolder
    }

    func getGoogleDriveLocationDescription() -> String? {
        guard isGoogleDriveFileURL else {
            return nil
        }
        return GoogleDriveURLHelper.getDescription(for: self)
    }
}

public enum GoogleDriveURLHelper {
    public static let schemePrefix = "keepassium"
    public static let scheme = "googledrive"
    public static let prefixedScheme = schemePrefix + String(urlSchemePrefixSeparator) + scheme

    private enum Key {
        static let id = "id"
        static let email = "email"
        static let driveID = "driveID"
        static let canCreateDrives = "canCreateDrives"
        static let scope = "scope"
    }

    static func build(from item: GoogleDriveItem) -> URL {
        assert(!item.isShortcut, "Only real items are supposed to make it to URLs")
        var queryItems = [
            URLQueryItem(name: Key.id, value: item.id),
            URLQueryItem(name: Key.email, value: item.accountInfo.email),
            URLQueryItem(name: Key.canCreateDrives, value: String(item.accountInfo.canCreateDrives))
        ]
        if let driveID = item.sharedDriveID {
            queryItems.append(URLQueryItem(name: Key.driveID, value: driveID))
        }
        if item.scope != .fullAccess {
            queryItems.append(URLQueryItem(name: Key.scope, value: item.scope.rawValue))
        }
        let result = URL.build(
            schemePrefix: schemePrefix,
            scheme: scheme,
            host: "googledrive",
            path: "/" + item.name,
            queryItems: queryItems
        )
        return result
    }

    public static func urlToItem(_ prefixedURL: URL) -> GoogleDriveItem? {
        guard prefixedURL.isGoogleDriveFileURL else {
            Diag.error("Not a GoogleDrive URL, cancelling")
            assertionFailure()
            return nil
        }
        let queryItems = prefixedURL.queryItems
        guard let id = queryItems[Key.id] else {
            Diag.error("File ID is missing, cancelling")
            assertionFailure()
            return nil
        }
        guard let email = queryItems[Key.email] else {
            Diag.error("Item account info is missing, cancelling")
            assertionFailure()
            return nil
        }

        let driveID = queryItems[Key.driveID]
        let canCreateDrives = (queryItems[Key.canCreateDrives] == "true")
        let accountInfo = GoogleDriveAccountInfo(email: email, canCreateDrives: canCreateDrives)
        let scope = getScope(from: prefixedURL)

        return GoogleDriveItem(
            name: prefixedURL.lastPathComponent,
            id: id,
            isFolder: false,
            isShortcut: false,
            accountInfo: accountInfo,
            scope: scope,
            sharedDriveID: driveID
        )
    }

    static func getDescription(for prefixedURL: URL) -> String? {
        guard let item = GoogleDriveItem.fromURL(prefixedURL) else {
            return LString.connectionTypeGoogleDrive + "(?)"
        }
        let fileProvider = item.accountInfo.getMatchingFileProvider(scope: item.scope)
        let serviceName = fileProvider.localizedName
        return "\(serviceName) (\(item.accountInfo.email))"
    }

    fileprivate static func getScope(from prefixedURL: URL) -> OAuthScope {
        assert(prefixedURL.isGoogleDriveFileURL)
        return prefixedURL.queryItems[Key.scope].flatMap { OAuthScope(rawValue: $0) } ?? .fullAccess
    }
}

extension GoogleDriveItem: SerializableRemoteFileItem  {
    public static func fromURL(_ prefixedURL: URL) -> GoogleDriveItem? {
        return GoogleDriveURLHelper.urlToItem(prefixedURL)
    }

    public func toURL() -> URL {
        return GoogleDriveURLHelper.build(from: self)
    }
}
