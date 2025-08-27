//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

public final class AddEntryURLOperation: DatabaseOperation {
    let uuid: UUID
    let modificationTime: Date
    let url: URL

    enum CodingKeys: String, CodingKey {
        case kind, uuid, modificationTime, url
    }

    init(uuid: UUID, modificationTime: Date, url: URL) {
        self.uuid = uuid
        self.modificationTime = modificationTime
        self.url = url
        super.init(kind: .addEntryURL)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        self.modificationTime = try container.decode(Date.self, forKey: .modificationTime)
        self.url = try container.decode(URL.self, forKey: .url)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(modificationTime, forKey: .modificationTime)
        try container.encode(url, forKey: .url)
        try super.encode(to: encoder)
    }

    override func apply(to databaseFile: DatabaseFile, recovery: RecoveryConfig?) throws {
        guard let entry = getEntry(in: databaseFile.database, recovery: recovery) as? Entry2 else {
            Diag.error("Entry not found [uuid: \(uuid)]")
            throw Error.entryNotFound
        }

        let urlString = url.absoluteString
        let alreadyExists = entry.fields.contains { field in
            field.resolvedValue == urlString && (field.name == EntryField.url || field.isExtraURL)
        }
        if alreadyExists {
            Diag.info("Entry already contains given URL, skipping")
            return
        }

        entry.backupState()
        entry.lastModificationTime = modificationTime
        if entry.rawURL.isEmpty {
            entry.rawURL = urlString
        } else {
            let newURLField = entry.makeExtraURLField(value: urlString)
            entry.fields.append(newURLField)
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

extension DatabaseOperation {
    public static func addEntryURL(_ url: URL, to entry: Entry) -> AddEntryURLOperation {
        return AddEntryURLOperation(uuid: entry.uuid, modificationTime: .now, url: url)
    }
}
