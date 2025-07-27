//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

public enum RemoteConnectionType: Hashable {
    public static let allValues: [RemoteConnectionType] = [
        .dropbox,
        .dropboxBusiness,
        .googleDrive,
        .googleWorkspace,
        .oneDrivePersonal(scope: .fullAccess),
        .oneDrivePersonal(scope: .appFolder),
        .oneDriveForBusiness(scope: .fullAccess),
        .oneDriveForBusiness(scope: .appFolder),
        .webdav,
    ]

    public static var availableValues: [RemoteConnectionType] {
        return allValues
    }

    case webdav
    case oneDrivePersonal(scope: OAuthScope)
    case oneDriveForBusiness(scope: OAuthScope)
    case dropbox
    case dropboxBusiness
    case googleDrive
    case googleWorkspace
}

extension RemoteConnectionType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .webdav:
            return LString.connectionTypeWebDAV
        case .oneDrivePersonal(let scope):
            switch scope {
            case .fullAccess:
                return FileProvider.keepassiumOneDrivePersonal.localizedName
            case .appFolder:
                return FileProvider.keepassiumOneDrivePersonalAppFolder.localizedName
            }
        case .oneDriveForBusiness(let scope):
            switch scope {
            case .fullAccess:
                return FileProvider.keepassiumOneDriveBusiness.localizedName
            case .appFolder:
                return FileProvider.keepassiumOneDriveBusinessAppFolder.localizedName
            }
        case .dropbox:
            return LString.connectionTypeDropbox
        case .dropboxBusiness:
            return LString.connectionTypeDropboxBusiness
        case .googleDrive:
            return LString.connectionTypeGoogleDrive
        case .googleWorkspace:
            return LString.connectionTypeGoogleWorkspace
        }
    }

    public var subtitle: String? {
        switch self {
        case .oneDrivePersonal(scope: .appFolder),
             .oneDriveForBusiness(scope: .appFolder):
            return LString.connectionTypeDedicatedAppFolder
        default:
            return nil
        }
    }

    public var fileProvider: FileProvider {
        switch self {
        case .webdav:
            return .keepassiumWebDAV
        case .oneDrivePersonal(let scope):
            switch scope {
            case .fullAccess:
                return .keepassiumOneDrivePersonal
            case .appFolder:
                return .keepassiumOneDrivePersonalAppFolder
            }
        case .oneDriveForBusiness(let scope):
            switch scope {
            case .fullAccess:
                return .keepassiumOneDriveBusiness
            case .appFolder:
                return .keepassiumOneDriveBusinessAppFolder
            }
        case .dropbox,
             .dropboxBusiness:
            return .keepassiumDropbox
        case .googleDrive, .googleWorkspace:
            return .keepassiumGoogleDrive
        }
    }
}

extension RemoteConnectionType {
    public var isBusinessCloud: Bool {
        switch self {
        case .webdav,
             .oneDrivePersonal,
             .dropbox,
             .googleDrive:
            return false
        case .oneDriveForBusiness,
             .dropboxBusiness,
             .googleWorkspace:
            return true
        }
    }

    public var isPremiumUpgradeRequired: Bool {
        return isBusinessCloud &&
               !PremiumManager.shared.isAvailable(feature: .canUseBusinessClouds)
    }
}
