//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

enum GroupViewerItem: Hashable, Equatable {
    case announcement(_ item: AnnouncementItem)
    case emptyStatePlaceholder(_ text: String) // "Nothing suitable found"
    case group(_ group: Group)
    case entry(_ entry: Entry)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.announcement(lhsItem), .announcement(rhsItem)):
            return lhsItem == rhsItem
        case (.emptyStatePlaceholder, .emptyStatePlaceholder):
            return true
        case let (.group(lhsItem), .group(rhsItem)):
            return lhsItem.runtimeUUID == rhsItem.runtimeUUID
        case let (.entry(lhsItem), .entry(rhsItem)):
            return lhsItem.runtimeUUID == rhsItem.runtimeUUID
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .announcement(let item):
            hasher.combine(item)
        case .emptyStatePlaceholder(let text):
            hasher.combine(text)
        case .group(let group):
            hasher.combine(group.runtimeUUID)
        case let .entry(entry):
            hasher.combine(entry.runtimeUUID)
        }
    }
}
