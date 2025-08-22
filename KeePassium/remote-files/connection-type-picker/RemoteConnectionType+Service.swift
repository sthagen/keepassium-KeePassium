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
        case webdav

        var description: String {
            switch self {
            case .dropbox:
                return LString.connectionTypeDropbox
            case .googleDrive:
                return LString.connectionTypeGoogleDrive
            case .oneDrive:
                return LString.connectionTypeOneDrive
            case .webdav:
                return LString.connectionTypeWebDAV
            }
        }

        func contains(connectionType: RemoteConnectionType) -> Bool {
            switch connectionType {
            case .dropbox, .dropboxBusiness:
                return self == .dropbox
            case .oneDrivePersonal, .oneDriveForBusiness:
                return self == .oneDrive
            case .googleDrive, .googleWorkspace:
                return self == .googleDrive
            case .webdav:
                return self == .webdav
            }
        }

        var iconSymbol: SymbolName? {
            switch self {
            case .dropbox:
                return FileProvider.keepassiumDropbox.iconSymbol
            case .googleDrive:
                return FileProvider.keepassiumGoogleDrive.iconSymbol
            case .oneDrive:
                return FileProvider.keepassiumOneDrivePersonal.iconSymbol
            case .webdav:
                return FileProvider.keepassiumWebDAV.iconSymbol
            }
        }
    }
}
