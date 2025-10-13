//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension RemoteConnectionType {

    enum Service: Hashable, CaseIterable, CustomStringConvertible {
        case dropbox
        case googleDrive
        case oneDrive
        case other

        var description: String {
            switch self {
            case .dropbox:
                return LString.connectionTypeDropbox
            case .googleDrive:
                return LString.connectionTypeGoogleDrive
            case .oneDrive:
                return LString.connectionTypeOneDrive
            case .other:
                return LString.connectionTypeOtherLocations
            }
        }

        func contains(connectionType: RemoteConnectionType) -> Bool {
            switch connectionType {
            case .dropboxPersonal, .dropboxBusiness:
                return self == .dropbox
            case .oneDrivePersonal, .oneDriveForBusiness:
                return self == .oneDrive
            case .googleDrive, .googleWorkspace:
                return self == .googleDrive
            case .genericHTTP,
                 .genericWebDAV,
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
                return self == .other
            }
        }

        var iconSymbol: SymbolName? {
            switch self {
            case .dropbox:
                return FileProvider.keepassiumDropboxPersonal.iconSymbol
            case .googleDrive:
                return FileProvider.keepassiumGoogleDrive.iconSymbol
            case .oneDrive:
                return FileProvider.keepassiumOneDrivePersonal.iconSymbol
            case .other:
                return .network
            }
        }
    }

    var iconSymbol: SymbolName? {
        guard fileProvider == .keepassiumWebDAV else {
            return fileProvider.iconSymbol
        }
        switch self {
        case .genericWebDAV: return .fileProviderWebDAV
        case .genericHTTP: return .fileProviderHTTP
        case .nextcloud: return .fileProviderNextCloud
        case .owncloud: return .fileProviderOwnCloud
        case .synology: return .fileProviderNAS
        default:
            return .fileProviderWebDAV
        }
    }
}
