//  KeePassium Password Manager
//  Copyright © 2018-2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

public final class CreateEntryOperation: DatabaseOperation {
    public let uuid: UUID
    public let parentUUID: UUID
    public let creationTime: Date

    enum CodingKeys: String, CodingKey {
        case kind, uuid, parentUUID, creationTime
    }

    init(uuid: UUID, parentUUID: UUID, creationTime: Date) {
        self.uuid = uuid
        self.parentUUID = parentUUID
        self.creationTime = creationTime
        super.init(kind: .createEntry)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.parentUUID = try container.decode(UUID.self, forKey: .parentUUID)
        self.creationTime = try container.decode(Date.self, forKey: .creationTime)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(parentUUID, forKey: .parentUUID)
        try container.encode(creationTime, forKey: .creationTime)
        try super.encode(to: encoder)
    }

    override func apply(to databaseFile: DatabaseFile, recovery: RecoveryConfig?) throws {
        let database = databaseFile.database

        guard let parent = getParentGroup(in: database, recovery: recovery) else {
           Diag.error("Parent group not found [uuid: \(parentUUID)]")
           throw Error.parentNotFound
        }

        let entry: Entry
        if let existingEntry = database.root?.findEntry(byUUID: uuid) {
            if recovery?.acceptIfExists == true {
                Diag.warning("Entry already exists, will use it [uuid: \(uuid)]")
                existingEntry.backupState()
                entry = existingEntry
            } else {
                Diag.error("Entry already exists [uuid: \(uuid)]")
                throw Error.entryAlreadyExists
            }
        } else {
            entry = parent.createEntry(detached: false, uuid: uuid)
        }
        entry.creationTime = creationTime
        entry.lastModificationTime = creationTime
        entry.lastAccessTime = creationTime
    }

    private func getParentGroup(in database: Database, recovery: RecoveryConfig?) -> Group? {
        if let foundParent = database.root?.findGroup(byUUID: parentUUID) {
            return foundParent
        }

        guard let recovery else {
            return nil
        }

        Diag.warning("Parent group not found, using recovery one [missing: \(parentUUID)]")
        return recovery.replacementParent
    }
}
