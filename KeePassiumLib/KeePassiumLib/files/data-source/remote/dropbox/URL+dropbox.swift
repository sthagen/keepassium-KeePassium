//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension URL {
    var isDropboxFileURL: Bool {
        return self.scheme == DropboxURLHelper.prefixedScheme
    }

    public var isDropboxAppFolderScopedURL: Bool {
        return isDropboxFileURL
            && DropboxURLHelper.getScope(from: self) == .appFolder
    }

    func getDropboxLocationDescription() -> String? {
        guard isDropboxFileURL else {
            return nil
        }
        return DropboxURLHelper.getDescription(for: self)
    }
}

public enum DropboxURLHelper {
    public static let schemePrefix = "keepassium"
    public static let scheme = "dropbox"
    public static let prefixedScheme = schemePrefix + String(urlSchemePrefixSeparator) + scheme

    private enum Key {
        static let name = "name"
        static let accountId = "accountId"
        static let email = "email"
        static let type = "type"
        static let scope = "scope"
    }

    static func build(from item: DropboxItem) -> URL {
        var queryItems = [
            URLQueryItem(name: Key.name, value: item.name),
            URLQueryItem(name: Key.accountId, value: item.info.accountId),
            URLQueryItem(name: Key.email, value: item.info.email),
            URLQueryItem(name: Key.type, value: item.info.type.rawValue)
        ]
        if item.scope != .fullAccess {
            queryItems.append(URLQueryItem(name: Key.scope, value: item.scope.rawValue))
        }
        let result = URL.build(
            schemePrefix: schemePrefix,
            scheme: scheme,
            host: "dropbox",
            path: item.pathDisplay,
            queryItems: queryItems
        )
        return result
    }

    public static func urlToItem(_ prefixedURL: URL) -> DropboxItem? {
        guard prefixedURL.isDropboxFileURL else {
            Diag.error("Not an Dropbox URL, cancelling")
            assertionFailure()
            return nil
        }
        let queryItems = prefixedURL.queryItems
        guard let name = queryItems[Key.name] else {
            Diag.error("File name is missing, cancelling")
            assertionFailure()
            return nil
        }
        let path: String = prefixedURL.path
        guard path.isNotEmpty else {
            Diag.error("Item path is empty, cancelling")
            assertionFailure()
            return nil
        }
        guard let accountId = queryItems[Key.accountId],
              let email = queryItems[Key.email],
              let type = DropboxAccountInfo.AccountType.from(queryItems[Key.type])
        else {
            Diag.error("Item info account id or email or type is empty, cancelling")
            assertionFailure()
            return nil
        }
        let scope = getScope(from: prefixedURL)
        return DropboxItem(
            name: name,
            isFolder: prefixedURL.hasDirectoryPath,
            fileInfo: nil,
            pathDisplay: path,
            info: DropboxAccountInfo(accountId: accountId, email: email, type: type),
            scope: scope
        )
    }

    static func getDescription(for prefixedURL: URL) -> String? {
        let queryItems = prefixedURL.queryItems
        let accountType = DropboxAccountInfo.AccountType.from(queryItems[Key.type])
        let scope = getScope(from: prefixedURL)
        let fileProvider = accountType?.getMatchingFileProvider(scope: scope) ?? .keepassiumDropbox
        let serviceName = fileProvider.localizedName
        let path = prefixedURL.relativePath
        let email = queryItems[Key.email] ?? "?"
        return "\(serviceName) (\(email)) → \(path)"
    }

    fileprivate static func getScope(from prefixedURL: URL) -> OAuthScope {
        assert(prefixedURL.isDropboxFileURL)
        return prefixedURL.queryItems[Key.scope].flatMap { OAuthScope(rawValue: $0) } ?? .fullAccess
    }
}

extension DropboxItem: SerializableRemoteFileItem {
    public static func fromURL(_ prefixedURL: URL) -> DropboxItem? {
        return DropboxURLHelper.urlToItem(prefixedURL)
    }

    public func toURL() -> URL {
        return DropboxURLHelper.build(from: self)
    }
}
