//  KeePassium Password Manager
//  Copyright © 2018-2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

public class DatabaseOperation: Codable {
    enum Kind: String, Codable {
        case createEntry
        case editEntry
        case addEntryURL
    }

    enum Error: LocalizedError {
        case entryNotFound
        case parentNotFound
        case entryAlreadyExists

        var errorDescription: String? {
            switch self {
            case .entryNotFound:
                return "Entry not found"
            case .parentNotFound:
                return "Parent not found"
            case .entryAlreadyExists:
                return "Entry already exists"
            }
        }
    }

    struct RecoveryConfig {
        var replacementParent: Group

        var acceptIfExists: Bool

        var createIfMissing: Bool
    }

    let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

    func apply(to databaseFile: DatabaseFile, recovery: RecoveryConfig? = nil) throws {
        fatalError("Pure abstract method")
    }
}
