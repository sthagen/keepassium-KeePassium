//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public enum EntryListDetail: Int {
        public static let allValues = [`none`, userName, password, url, notes, tags, lastModifiedDate]

        case none
        case userName
        case password
        case url
        case notes
        case lastModifiedDate
        case tags

        public var title: String {
            // swiftlint:disable line_length
            switch self {
            case .none:
                return NSLocalizedString(
                    "[Settings/EntryListDetail/longTitle] None",
                    bundle: Bundle.framework,
                    value: "None",
                    comment: "An option in Group Viewer settings. Will be shown as 'Entry Subtitle: None', meanining that no entry details will be shown in any lists.")
            case .userName:
                return LString.fieldUserName
            case .password:
                return LString.fieldPassword
            case .url:
                return LString.fieldURL
            case .notes:
                return LString.fieldNotes
            case .lastModifiedDate:
                return LString.itemLastModificationDate
            case .tags:
                return LString.fieldTags
            }
            // swiftlint:enable line_length
        }
    }

    public enum FieldMenuMode: Int, CaseIterable {
        case full = 0
        case compact = 1
    }

    public enum GroupSortOrder: Int {
        public static let allValues = [
            noSorting,
            nameAsc, nameDesc,
            creationTimeDesc, creationTimeAsc,
            modificationTimeDesc, modificationTimeAsc]

        case noSorting
        case nameAsc
        case nameDesc
        case creationTimeAsc
        case creationTimeDesc
        case modificationTimeAsc
        case modificationTimeDesc

        public var isAscending: Bool? {
            switch self {
            case .noSorting:
                return nil
            case .nameAsc, .creationTimeAsc, .modificationTimeAsc:
                return true
            case .nameDesc, .creationTimeDesc, .modificationTimeDesc:
                return false
            }
        }

        public var title: String {
            switch self {
            case .noSorting:
                return LString.titleSortOrderCustom
            case .nameAsc, .nameDesc:
                return LString.fieldTitle
            case .creationTimeAsc, .creationTimeDesc:
                return LString.itemCreationDate
            case .modificationTimeAsc, .modificationTimeDesc:
                return LString.itemLastModificationDate
            }
        }
        public func compare(_ group1: Group, _ group2: Group) -> Bool {
            switch self {
            case .noSorting:
                return false
            case .nameAsc:
                return group1.name.localizedStandardCompare(group2.name) == .orderedAscending
            case .nameDesc:
                return group1.name.localizedStandardCompare(group2.name) == .orderedDescending
            case .creationTimeAsc:
                return group1.creationTime.compare(group2.creationTime) == .orderedAscending
            case .creationTimeDesc:
                return group1.creationTime.compare(group2.creationTime) == .orderedDescending
            case .modificationTimeAsc:
                return group1.lastModificationTime.compare(group2.lastModificationTime) == .orderedAscending
            case .modificationTimeDesc:
                return group1.lastModificationTime.compare(group2.lastModificationTime) == .orderedDescending
            }
        }
        public func compare(_ entry1: Entry, _ entry2: Entry) -> Bool {
            switch self {
            case .noSorting:
                return false
            case .nameAsc:
                return entry1.resolvedTitle.localizedStandardCompare(entry2.resolvedTitle) == .orderedAscending
            case .nameDesc:
                return entry1.resolvedTitle.localizedStandardCompare(entry2.resolvedTitle) == .orderedDescending
            case .creationTimeAsc:
                return entry1.creationTime.compare(entry2.creationTime) == .orderedAscending
            case .creationTimeDesc:
                return entry1.creationTime.compare(entry2.creationTime) == .orderedDescending
            case .modificationTimeAsc:
                return entry1.lastModificationTime.compare(entry2.lastModificationTime) == .orderedAscending
            case .modificationTimeDesc:
                return entry1.lastModificationTime.compare(entry2.lastModificationTime) == .orderedDescending
            }
        }
    }

    public var databaseIconSet: DatabaseIconSet {
        get {
            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.databaseIconSet.rawValue) as? Int,
               let iconSet = DatabaseIconSet(rawValue: rawValue)
            {
                return iconSet
            }
            return DatabaseIconSet.keepassium
        }
        set {
            _updateAndNotify(oldValue: databaseIconSet.rawValue, newValue: newValue.rawValue, key: .databaseIconSet)
        }
    }

    public var groupSortOrder: GroupSortOrder {
        get {
            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.groupSortOrder.rawValue) as? Int,
               let sortOrder = GroupSortOrder(rawValue: rawValue)
            {
                return sortOrder
            }
            return GroupSortOrder.noSorting
        }
        set {
            let oldValue = groupSortOrder
            UserDefaults.appGroupShared.set(newValue.rawValue, forKey: Keys.groupSortOrder.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.groupSortOrder)
            }
        }
    }

    public var entryListDetail: EntryListDetail {
        get {
            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.entryListDetail.rawValue) as? Int,
               let detail = EntryListDetail(rawValue: rawValue)
            {
                return detail
            }
            return EntryListDetail.userName
        }
        set {
            let oldValue = entryListDetail
            UserDefaults.appGroupShared.set(newValue.rawValue, forKey: Keys.entryListDetail.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.entryListDetail)
            }
        }
    }

    public var entryViewerPage: Int {
        get {
            let storedPage = UserDefaults.appGroupShared
                .object(forKey: Keys.entryViewerPage.rawValue) as? Int
            return storedPage ?? 0
        }
        set {
            _updateAndNotify(
                oldValue: entryViewerPage,
                newValue: newValue,
                key: Keys.entryViewerPage)
        }
    }

    public var isRememberEntryViewerPage: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.rememberEntryViewerPage.rawValue)
                as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isRememberEntryViewerPage,
                newValue: newValue,
                key: .rememberEntryViewerPage)
        }
    }

    public var isHideProtectedFields: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.hideProtectedFields) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.hideProtectedFields.rawValue) as? Bool
            return stored ?? true
        }
        set {
            _updateAndNotify(
                oldValue: isHideProtectedFields,
                newValue: newValue,
                key: Keys.hideProtectedFields)
        }
    }

    public var isCollapseNotesField: Bool {
        get {
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.collapseNotesField.rawValue) as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isCollapseNotesField,
                newValue: newValue,
                key: Keys.collapseNotesField)
        }
    }

}
