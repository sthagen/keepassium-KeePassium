//  KeePassium Password Manager
//  Copyright © 2018-2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

public final class EditEntryOperation: DatabaseOperation {
    let uuid: UUID
    let modificationTime: Date
    private(set) var fields: [EntryField]

    enum CodingKeys: String, CodingKey {
        case kind, uuid, modificationTime, fields
    }

    init(uuid: UUID, modificationTime: Date, fields: [EntryField]) {
        self.uuid = uuid
        self.modificationTime = modificationTime
        self.fields = fields
        super.init(kind: .editEntry)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.modificationTime = try container.decode(Date.self, forKey: .modificationTime)
        self.fields = try container.decode([EntryField].self, forKey: .fields)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(modificationTime, forKey: .modificationTime)
        try container.encode(fields, forKey: .fields)
        try super.encode(to: encoder)
    }

    func addFieldChange(name: String, value: String, isProtected: Bool = false) {
        fields.append(EntryField(name: name, value: value, isProtected: isProtected))
    }

    override func apply(to databaseFile: DatabaseFile, recovery: RecoveryConfig?) throws {
        guard let entry = getEntry(in: databaseFile.database, recovery: recovery) else {
            Diag.error("Entry not found [uuid: \(uuid)]")
            throw Error.entryNotFound
        }

        entry.backupState()
        entry.lastModificationTime = modificationTime
        fields.forEach { field in
            entry.setField(name: field.name, value: field.value, isProtected: field.isProtected)
        }

        QuickTypeAutoFillStorage.saveIdentities(from: entry, in: databaseFile)
    }

    private func getEntry(in database: Database, recovery: RecoveryConfig?) -> Entry? {
        if let entry = database.root?.findEntry(byUUID: uuid) {
            return entry
        }
        guard let recovery,
              recovery.createIfMissing
        else {
            return nil
        }

        Diag.warning("Entry not found, creating it in the replacement group [uuid: \(uuid)]")
        let parent = recovery.replacementParent
        let entry = parent.createEntry(detached: false, uuid: uuid)
        return entry
    }
}
