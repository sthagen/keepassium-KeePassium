//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension DatabaseOperation {
    public static func createEntry(in group: Group) -> CreateEntryOperation {
        return CreateEntryOperation(uuid: UUID(), parentUUID: group.uuid, creationTime: .now)
    }

    public static func createEntry(
        uuid: UUID,
        title: String,
        username: String,
        password: String,
        url: String,
        notes: String,
        in group: Group
    ) -> [DatabaseOperation] {
        let createOp = CreateEntryOperation(uuid: uuid, parentUUID: group.uuid, creationTime: .now)
        let editOp = EditEntryOperation(uuid: uuid, modificationTime: .now, fields: [
            EntryField(name: EntryField.title, value: title, isProtected: false),
            EntryField(name: EntryField.userName, value: username, isProtected: false),
            EntryField(name: EntryField.password, value: password, isProtected: true),
            EntryField(name: EntryField.url, value: url, isProtected: false),
            EntryField(name: EntryField.notes, value: notes, isProtected: false),
        ])
        return [createOp, editOp]
    }
}
