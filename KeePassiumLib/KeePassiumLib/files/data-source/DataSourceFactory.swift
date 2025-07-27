//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

internal final class DataSourceFactory {

    public static func getDataSource(for url: URL) -> DataSource {
        guard let urlSchemePrefix = url.schemePrefix else {
            return LocalDataSource()
        }

        let detectedFileProvider = findInAppFileProvider(for: url)
        switch detectedFileProvider {
        case .keepassiumWebDAV:
            return WebDAVDataSource()
        case .keepassiumOneDrivePersonal,
             .keepassiumOneDrivePersonalAppFolder,
             .keepassiumOneDriveBusiness,
             .keepassiumOneDriveBusinessAppFolder:
            return OneDriveDataSource(fileProvider: detectedFileProvider!)
        case .keepassiumDropbox:
            return DropboxDataSource()
        case .keepassiumGoogleDrive:
            return GoogleDriveDataSource()
        default:
            Diag.warning("Unexpected URL format, assuming local file [prefix: \(urlSchemePrefix)]")
            return LocalDataSource()
        }
    }

    public static func findInAppFileProvider(for url: URL) -> FileProvider? {
        if url.isWebDAVFileURL {
            return .keepassiumWebDAV
        } else if url.isDropboxFileURL {
            return .keepassiumDropbox
        } else if url.isGoogleDriveFileURL {
            return .keepassiumGoogleDrive
        } else if url.isOneDrivePersonalFileURL {
            if url.isOneDriveAppFolderScopedURL {
                return .keepassiumOneDrivePersonalAppFolder
            } else {
                return .keepassiumOneDrivePersonal
            }
        } else if url.isOneDriveBusinessFileURL {
            if url.isOneDriveAppFolderScopedURL {
                return .keepassiumOneDriveBusinessAppFolder
            } else {
                return .keepassiumOneDriveBusiness
            }
        }
        return nil
    }
}
