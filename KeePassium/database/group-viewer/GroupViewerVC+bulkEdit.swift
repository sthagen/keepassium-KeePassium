//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension GroupViewerVC {
    public func startReordering() {
        setEditing(true, animated: true)
    }

    public func startSelecting() {
        setEditing(true, animated: true)
    }

    public func endBulkEditing(animated: Bool) {
        setEditing(false, animated: animated)
        switch _items {
        case .foundManually, .smartGroup:
            return
        case .standard:
            break
        }
    }
}

extension GroupViewerVC {
    internal func _canReorderItem(_ item: Item) -> Bool {
        guard let delegate, delegate.shouldAllowReorder(in: self) else {
            return false
        }

        switch (_items, item) {
        case (.foundManually, _),
             (.smartGroup, _),
             (.standard, .announcement),
             (.standard, .emptyStatePlaceholder):
            return false
        case (.standard, .group),
             (.standard, .entry):
            return true
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
        atCurrentIndexPath currentIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        let originalSection = _dataSource.sectionIdentifier(for: originalIndexPath.section)
        let proposedSection = _dataSource.sectionIdentifier(for: proposedIndexPath.section)

        switch originalSection {
        case .announcements, .foundCluster:
            assertionFailure("Tried to reorder a fixed item")
            return originalIndexPath
        case .groups:
            guard case .groups = proposedSection else {
                return originalIndexPath
            }
            return proposedIndexPath
        case .entries:
            guard case .entries = proposedSection else {
                return originalIndexPath
            }
            return proposedIndexPath
        case .none:
            assertionFailure()
            return originalIndexPath
        }
    }

    internal func _didReorderItems(_ transaction: NSDiffableDataSourceTransaction<Section, Item>) {
        if transaction.difference.isEmpty {
            return
        }

        switch _items {
        case .foundManually, .smartGroup:
            Diag.error("Unexpected reordering while in search mode, ignoring")
            assertionFailure()
            return
        case .standard:
            break
        }
        _notifyNewItemOrder(items: transaction.finalSnapshot.itemIdentifiers)
    }

    internal func _notifyNewItemOrder(items: [Item]) {
        var newGroupsOrder = [Group]()
        var newEntryOrder = [Entry]()
        for item in items {
            if case let .group(group) = item {
                newGroupsOrder.append(group)
            } else if case let .entry(entry) = item {
                newEntryOrder.append(entry)
            }
        }

        delegate?.didReorderItems(
            of: _group,
            groups: newGroupsOrder,
            entries: newEntryOrder,
            in: self
        )
    }
}
