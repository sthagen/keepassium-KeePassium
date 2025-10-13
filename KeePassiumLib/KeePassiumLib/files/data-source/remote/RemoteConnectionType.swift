//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

public enum RemoteConnectionType: Hashable {
    public static let allValues: [RemoteConnectionType] = [
        .dropboxPersonal(scope: .fullAccess),
        .dropboxPersonal(scope: .appFolder),
        .dropboxBusiness(scope: .fullAccess),
        .dropboxBusiness(scope: .appFolder),
        .googleDrive(scope: .fullAccess),
        .googleDrive(scope: .appFolder),
        .googleWorkspace(scope: .fullAccess),
        .googleWorkspace(scope: .appFolder),
        .oneDrivePersonal(scope: .fullAccess),
        .oneDrivePersonal(scope: .appFolder),
        .oneDriveForBusiness(scope: .fullAccess),
        .oneDriveForBusiness(scope: .appFolder),
        .genericHTTP,
        .hetzner,
        .hiDriveIonos,
        .hiDriveStrato,
        .koofr,
        .magentaCloud,
        .nextcloud,
        .owncloud,
        .qnap,
        .synology,
        .genericWebDAV,
        .woelkli,
    ]

    case oneDrivePersonal(scope: OAuthScope)
    case oneDriveForBusiness(scope: OAuthScope)
    case dropboxPersonal(scope: OAuthScope)
    case dropboxBusiness(scope: OAuthScope)
    case googleDrive(scope: OAuthScope)
    case googleWorkspace(scope: OAuthScope)
    case genericWebDAV
    case genericHTTP
    case hetzner
    case hiDriveIonos
    case hiDriveStrato
    case koofr
    case magentaCloud
    case nextcloud
    case owncloud
    case qnap
    case synology
    case woelkli
}

extension RemoteConnectionType: CustomStringConvertible {
    public var description: String {
        switch self {
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
        case .dropboxPersonal(let scope):
            switch scope {
            case .fullAccess:
                return FileProvider.keepassiumDropboxPersonal.localizedName
            case .appFolder:
                return FileProvider.keepassiumDropboxPersonalAppFolder.localizedName
            }
        case .dropboxBusiness(let scope):
            switch scope {
            case .fullAccess:
                return FileProvider.keepassiumDropboxBusiness.localizedName
            case .appFolder:
                return FileProvider.keepassiumDropboxBusinessAppFolder.localizedName
            }
        case .googleDrive(let scope):
            switch scope {
            case .fullAccess:
                return FileProvider.keepassiumGoogleDrive.localizedName
            case .appFolder:
                return FileProvider.keepassiumGoogleDriveAppFolder.localizedName
            }
        case .googleWorkspace(let scope):
            switch scope {
            case .fullAccess:
                return LString.connectionTypeGoogleWorkspace
            case .appFolder:
                return FileProvider.decorateForAppFolderScope(LString.connectionTypeGoogleWorkspace)
            }
        case .genericWebDAV:
            return LString.connectionTypeWebDAV
        case .genericHTTP:
            return LString.connectionTypeHTTP
        case .hetzner:
            return LString.connectionTypeHetzner
        case .hiDriveIonos:
            return LString.connectionTypeHiDriveIonos
        case .hiDriveStrato:
            return LString.connectionTypeHiDriveStrato
        case .koofr:
            return LString.connectionTypeKoofr
        case .magentaCloud:
            return LString.connectionTypeMagentaCloud
        case .nextcloud:
            return LString.connectionTypeNextcloud
        case .owncloud:
            return LString.connectionTypeOwnCloud
        case .qnap:
            return LString.connectionTypeQNAP
        case .synology:
            return LString.connectionTypeSynology
        case .woelkli:
            return LString.connectionTypeWoelkli
        }
    }

    public var subtitle: String? {
        switch self {
        case .oneDrivePersonal(scope: .appFolder),
             .oneDriveForBusiness(scope: .appFolder),
             .dropboxPersonal(scope: .appFolder),
             .dropboxBusiness(scope: .appFolder),
             .googleDrive(scope: .appFolder),
             .googleWorkspace(scope: .appFolder):
            return LString.connectionTypeDedicatedAppFolder
        default:
            return nil
        }
    }

    public var fileProvider: FileProvider {
        switch self {
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
        case .dropboxPersonal(let scope):
            switch scope {
            case .fullAccess:
                return .keepassiumDropboxPersonal
            case .appFolder:
                return .keepassiumDropboxPersonalAppFolder
            }
        case .dropboxBusiness(let scope):
            switch scope {
            case .fullAccess:
                return .keepassiumDropboxBusiness
            case .appFolder:
                return .keepassiumDropboxBusinessAppFolder
            }
        case .googleDrive(let scope), .googleWorkspace(let scope):
            switch scope {
            case .fullAccess:
                return .keepassiumGoogleDrive
            case .appFolder:
                return .keepassiumGoogleDriveAppFolder
            }
        case .genericWebDAV,
             .genericHTTP,
             .hetzner,
             .hiDriveIonos,
             .hiDriveStrato,
             .koofr,
             .magentaCloud,
             .nextcloud,
             .owncloud,
             .qnap,
             .synology,
             .woelkli:
            return .keepassiumWebDAV
        }
    }
}

extension RemoteConnectionType {
    public var isBusinessCloud: Bool {
        switch self {
        case .oneDrivePersonal,
             .dropboxPersonal,
             .googleDrive,
             .genericWebDAV,
             .genericHTTP,
             .hetzner,
             .hiDriveIonos,
             .hiDriveStrato,
             .koofr,
             .magentaCloud,
             .nextcloud,
             .owncloud,
             .qnap,
             .synology,
             .woelkli:
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
