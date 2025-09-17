//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryCreatorVC {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>

    enum Section: Int, CaseIterable {
        case announcements
        case entryFields
        case location
    }

    enum Item: Hashable, Equatable {
        case announcement(_ item: AnnouncementItem)
        case entryField(_ fieldConfig: EntryCreatorFieldConfiguration)
        case location(_ group: Group)

        static func == (lhs: EntryCreatorVC.Item, rhs: EntryCreatorVC.Item) -> Bool {
            switch (lhs, rhs) {
            case let (.announcement(lhsItem), .announcement(rhsItem)):
                return lhsItem == rhsItem
            case let (.entryField(lhsField), .entryField(rhsField)):
                return lhsField == rhsField
            case let (.location(lhsGroup), .location(rhsGroup)):
                return lhsGroup.runtimeUUID == rhsGroup.runtimeUUID
            default:
                return false
            }
        }
        func hash(into hasher: inout Hasher) {
            switch self {
            case .announcement(let announcement):
                hasher.combine(announcement)
            case .entryField(let fieldConfig):
                hasher.combine(fieldConfig)
            case .location(let group):
                hasher.combine(group.runtimeUUID)
            }
        }
    }
}

extension EntryCreatorVC {
    public func setAnnouncements(_ announcements: [AnnouncementItem]) {
        self._announcements = announcements.map {
            Item.announcement($0)
        }
    }

    public func setEntryData(_ entryData: EntryCreatorEntryData) {
        var fieldItems = [Item]()
        fieldItems.append(.entryField(EntryCreatorFieldConfiguration(
            name: EntryField.title,
            value: entryData.title,
            kind: .text)))
        fieldItems.append(.entryField(EntryCreatorFieldConfiguration(
            name: EntryField.userName,
            value: entryData.username,
            kind: .text)))
        fieldItems.append(.entryField(EntryCreatorFieldConfiguration(
            name: EntryField.password,
            value: entryData.password,
            kind: .password(hidden: entryData.isPasswordProtected))))
        fieldItems.append(.entryField(EntryCreatorFieldConfiguration(
            name: EntryField.url,
            value: entryData.url,
            kind: .url)))
        fieldItems.append(.entryField(EntryCreatorFieldConfiguration(
            name: EntryField.notes,
            value: entryData.notes,
            kind: .text)))
        _entryFields = fieldItems
    }

    public func setLocation(_ group: Group) {
        _locationItems = [.location(group)]
    }

    func _applySnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        if !_announcements.isEmpty {
            snapshot.appendSection(.announcements)
            snapshot.appendItems(_announcements)
            snapshot.reconfigureItems(_announcements)
        }
        snapshot.appendSection(.entryFields)
        snapshot.appendItems(_entryFields)

        snapshot.appendSection(.location)
        snapshot.appendItems(_locationItems)
        _dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
