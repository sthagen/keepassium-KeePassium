//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension GroupViewerVC {
    private static let maxAnnouncementsForFullSizePlaceholder = 0

    private static let minItemsForStatsFooter = 4

    typealias Item = GroupViewerItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>

    enum DataViewModel {
        static let empty = Self.standard(groups: [], entries: [])
        case standard(groups: [Item], entries: [Item])
        case smartGroup(_ foundClusters: [FoundCluster])
        case foundManually(_ foundClusters: [FoundCluster])
    }

    enum Section: Hashable {
        case announcements
        case groups(footer: String?)
        case entries(footer: String?)
        case foundCluster(header: String?, footer: String?)

        public var headerTitle: String? {
            switch self {
            case .announcements, .groups, .entries:
                return nil
            case let .foundCluster(header, _):
                return header
            }
        }
        public var footerText: String? {
            switch self {
            case .announcements:
                return nil
            case let .groups(footer),
                 let .entries(footer):
                return footer
            case let .foundCluster(_, footer):
                return footer
            }
        }
    }

    struct FoundCluster {
        var groupName: String?
        var items: [Item]
    }

    public func setAnnouncements(_ announcements: [AnnouncementItem]) {
        self._announcements = announcements.map {
            Item.announcement($0)
        }
    }

    public func setStandardGroupContents(groups: [Group], entries: [Entry]) {
        self.title = _group.name
        let sortOrder = Settings.current.groupSortOrder
        let sortedGroups = groups.sorted { sortOrder.compare($0, $1) }
        let sortedEntries = entries.sorted { sortOrder.compare($0, $1) }
        self._items = .standard(
            groups: sortedGroups.map { Item.group($0) },
            entries: sortedEntries.map { Item.entry($0) }
        )
        _otpDisplayMode = .protected
        _otpDisplayModeForItem.removeAll()
    }

    public func setSmartGroupContents(_ searchResults: SearchResults, prominentOTPs: Bool) {
        setManualSearchResults(searchResults)
        title = _group.name

        _otpDisplayModeForItem.removeAll()
        _otpDisplayMode = prominentOTPs ? .prominent : .protected
    }

    public func setManualSearchResults(_ searchResults: SearchResults) {
        var sortedSearchResults = searchResults
        sortedSearchResults.sort(order: Settings.current.groupSortOrder)

        var clusters = [FoundCluster]()
        for searchResult in sortedSearchResults {
            let cluster = FoundCluster(
                groupName: searchResult.group.name,
                items: searchResult.scoredItems.compactMap {
                    if let group = $0.item as? Group {
                        return Item.group(group)
                    } else if let entry = $0.item as? Entry {
                        return Item.entry(entry)
                    } else {
                        assertionFailure("Unexpected item type")
                        return nil
                    }
                }
            )
            clusters.append(cluster)
        }
        self._items = .foundManually(clusters)
        _otpDisplayMode = .protected
        _otpDisplayModeForItem.removeAll()
        title = LString.titleSearch
    }
}

extension GroupViewerVC {
    internal func _applySnapshot(animated: Bool) {
        assert(Thread.isMainThread)
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        if _announcements.count > 0 {
            snapshot.appendSection(.announcements)
            snapshot.appendItems(_announcements)
            snapshot.reconfigureItems(_announcements)
        }

        switch _items {
        case let .standard(groupItems, entryItems):
            populateStandardViewSnapshot(&snapshot, groups: groupItems, entries: entryItems)
        case .smartGroup(let foundClusters):
            populateSearchResultSnapshot(&snapshot, with: foundClusters)
        case .foundManually(let foundClusters):
            populateSearchResultSnapshot(&snapshot, with: foundClusters)
        }
        _collectionView.performBatchUpdates(nil) { _ in
            self._dataSource.apply(snapshot, animatingDifferences: animated)
        }
    }

    private func populateStandardViewSnapshot(
        _ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>,
        groups groupItems: [Item],
        entries entryItems: [Item]
    ) {
        if groupItems.isEmpty && entryItems.isEmpty {
            populateEmptyGroupPlaceholder(&snapshot)
            return
        }

        var itemCountText: String?
        let itemCount = groupItems.count + entryItems.count
        if itemCount >= Self.minItemsForStatsFooter {
            itemCountText = String.localizedStringWithFormat(LString.itemsCountTemplate, itemCount)
        }

        if groupItems.count > 0 {
            snapshot.appendSection(.groups(footer: entryItems.isEmpty ? itemCountText : nil))
            snapshot.appendItems(groupItems)
            snapshot.reconfigureItems(groupItems)
        }
        if entryItems.count > 0 {
            snapshot.appendSection(.entries(footer: itemCountText))
            snapshot.appendItems(entryItems)
            snapshot.reconfigureItems(entryItems)
        }
        contentUnavailableConfiguration = nil
    }

    private func populateEmptyGroupPlaceholder(
        _ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>
    ) {
        if _announcements.count <= Self.maxAnnouncementsForFullSizePlaceholder {
            contentUnavailableConfiguration = _emptySpaceDecorator?.getEmptyGroupConfiguration()
        } else {
            contentUnavailableConfiguration = nil
            let placeholderItem = Item.emptyStatePlaceholder(LString.titleThisGroupIsEmpty)
            snapshot.appendSection(.groups(footer: nil))
            snapshot.appendItems([placeholderItem])
        }
    }

    private func populateSearchResultSnapshot(
        _ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>,
        with foundClusters: [FoundCluster]
    ){
        if foundClusters.isEmpty {
            populateEmptySearchPlaceholder(&snapshot)
            return
        }

        var itemCountText: String?
        let itemCount = foundClusters.reduce(0) { $0 + $1.items.count }
        if itemCount >= Self.minItemsForStatsFooter {
            itemCountText = String.localizedStringWithFormat(LString.itemsCountTemplate, itemCount)
        }

        let lastIndex = foundClusters.count - 1
        foundClusters.enumerated().forEach { index, cluster in
            if index < lastIndex {
                snapshot.appendSection(.foundCluster(header: cluster.groupName, footer: nil))
            } else {
                snapshot.appendSection(.foundCluster(header: cluster.groupName, footer: itemCountText))
            }
            assert(!cluster.items.isEmpty, "Unexpectedly found an empty cluster")
            snapshot.appendItems(cluster.items)
            snapshot.reconfigureItems(cluster.items)
        }
        contentUnavailableConfiguration = nil
    }

    private func populateEmptySearchPlaceholder(
        _ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>
    ) {
        if _announcements.count <= Self.maxAnnouncementsForFullSizePlaceholder {
            contentUnavailableConfiguration = _emptySpaceDecorator?.getNothingFoundConfiguration()
        } else {
            contentUnavailableConfiguration = nil
            let placeholderItem = Item.emptyStatePlaceholder(LString.titleNothingSuitableFound)
            snapshot.appendSection(.groups(footer: nil))
            snapshot.appendItems([placeholderItem])
        }
    }
}

extension GroupViewerVC {
    internal func _getSelectedDatabaseItems() -> [DatabaseItem] {
        let selectedItems = _collectionView.indexPathsForSelectedItems?.compactMap {
            _dataSource.itemIdentifier(for: $0)
        }
        let databaseItems = selectedItems?.compactMap { dataItem -> DatabaseItem? in
            switch dataItem {
            case .announcement, .emptyStatePlaceholder:
                return nil
            case .group(let group):
                return group
            case .entry(let entry):
                return entry
            }
        }
        return databaseItems ?? []
    }

    internal func _getIndexPath(for entry: Entry) -> IndexPath? {
        switch _items {
        case let .standard(_, entryItems):
            return findEntry(by: entry.runtimeUUID, in: entryItems)
        case .smartGroup(let foundClusters),
             .foundManually(let foundClusters):
            for cluster in foundClusters {
                if let entry = findEntry(by: entry.runtimeUUID, in: cluster.items) {
                    return entry
                }
            }
            return nil
        }
    }

    private func findEntry(by runtimeUUID: UUID, in items: [Item]) -> IndexPath? {
        let itemByUUID = items.first(where: {
            if case let .entry(entry) = $0 {
                return entry.runtimeUUID == runtimeUUID
            } else {
                return false
            }
        })
        if let itemByUUID {
            return _dataSource.indexPath(for: itemByUUID)
        }
        return nil
    }
}
