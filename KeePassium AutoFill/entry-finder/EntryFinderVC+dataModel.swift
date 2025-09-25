//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
import UIKit

extension EntryFinderVC {

    enum DataViewModel {
        static let empty = Self.overview(SectionSnapshot())

        case overview(_ snapshot: SectionSnapshot)
        case foundManually(_ snapshot: SectionSnapshot)
        case foundAutomatically(_ snapshot: SectionSnapshot)
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>

    enum Section: Int, CaseIterable {
        case announcements
        case recentEntry
        case allItems
        case foundItems
        case context

        public var headerTitle: String? {
            switch self {
            case .announcements: return nil
            case .recentEntry: return LString.autoFillRecentlyUsedSectionTitle
            case .allItems: return LString.autoFillAllEntriesSectionTitle
            case .foundItems: return LString.autoFillFoundEntriesSectionTitle
            case .context: return LString.titleAutoFillContext
            }
        }
        public var footerText: String? { nil }
    }

    enum Item: Hashable, Equatable {
        enum Kind: Hashable, Equatable {
            case recent
            case exact
            case standard
        }
        case announcement(_ item: AnnouncementItem)
        case entryCreator(needsPremium: Bool)
        case emptyStatePlaceholder(_ text: String) // "Nothing suitable found"
        case group(_ group: Group, _ kind: Kind)
        case entry(_ entry: Entry, _ kind: Kind)
        case field(_ field: EntryField, _ entry: Entry, _ kind: Kind)
        case autoFillContext(_ text: String)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.announcement(lhsItem), .announcement(rhsItem)):
                return lhsItem == rhsItem
            case (.emptyStatePlaceholder, .emptyStatePlaceholder):
                return true
            case let (.group(lhsItem, lhsKind), .group(rhsItem, rhsKind)):
                return lhsItem.runtimeUUID == rhsItem.runtimeUUID
                    && lhsKind == rhsKind
            case let (.entry(lhsItem, lhsKind), .entry(rhsItem, rhsKind)):
                return lhsItem.runtimeUUID == rhsItem.runtimeUUID
                    && lhsKind == rhsKind
            case let (.field(lhsField, lhsEntry, lhsKind), .field(rhsField, rhsEntry, rhsKind)):
                return lhsField == rhsField
                    && lhsEntry.runtimeUUID == rhsEntry.runtimeUUID
                    && lhsKind == rhsKind
            case let (.autoFillContext(lhsText), .autoFillContext(rhsText)):
                return lhsText == rhsText
            default:
                return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .announcement(let item):
                hasher.combine(item)
            case .entryCreator(let needsPremium):
                hasher.combine(needsPremium)
            case .emptyStatePlaceholder(let text):
                hasher.combine(text)
            case let .group(group, kind):
                hasher.combine(group.runtimeUUID)
                hasher.combine(kind)
            case let .entry(entry, kind):
                hasher.combine(entry.runtimeUUID)
                hasher.combine(kind)
            case let .field(field, entry, kind):
                hasher.combine(field)
                hasher.combine(entry.runtimeUUID)
                hasher.combine(kind)
            case .autoFillContext(let text):
                hasher.combine(text)
            }
        }
    }
}

extension EntryFinderVC {
    public func setAnnouncements(_ announcements: [AnnouncementItem]) {
        self._announcements = announcements.map {
            Item.announcement($0)
        }
    }

    public func setRecentEntry(_ recentEntry: Entry?) {
        _recentEntrySection.deleteAll()
        guard let recentEntry else {
            return
        }

        if self.isFieldPickerMode {
            appendEntryWithFields(recentEntry, kind: .recent, to: &_recentEntrySection)
        } else {
            _recentEntrySection.append([Item.entry(recentEntry, .recent)])
        }
    }

    public func setOverviewData(_ groupedItems: [GroupedItems]) {
        var itemsSnapshot = SectionSnapshot()
        groupedItems.forEach {
            addGroupedItems($0, kind: .standard, to: &itemsSnapshot, includeFields: isFieldPickerMode)
        }
        if itemsSnapshot.items.isEmpty {
            itemsSnapshot.append([.emptyStatePlaceholder(LString.titleNothingSuitableFound)])
        }
        appendEntryCreatorItem(to: &itemsSnapshot)
        self._items = .overview(itemsSnapshot)
    }

    public func setManuallyFoundData(_ foundItems: [GroupedItems]) {
        var itemsSnapshot = SectionSnapshot()
        foundItems.forEach {
            addGroupedItems($0, kind: .standard, to: &itemsSnapshot, includeFields: isFieldPickerMode)
        }
        if itemsSnapshot.items.isEmpty {
            itemsSnapshot.append([.emptyStatePlaceholder(LString.titleNothingSuitableFound)])
        }
        appendEntryCreatorItem(to: &itemsSnapshot)
        self._items = .foundManually(itemsSnapshot)
    }

    public func setAutomaticallyFoundData(_ searchResults: FuzzySearchResults) {
        var foundItemsSnapshot = SectionSnapshot()
        searchResults.exactMatch.forEach {
            addGroupedItems($0, kind: .exact, to: &foundItemsSnapshot, includeFields: isFieldPickerMode)
        }
        searchResults.partialMatch.forEach {
            addGroupedItems($0, kind: .standard, to: &foundItemsSnapshot, includeFields: isFieldPickerMode)
        }
        if foundItemsSnapshot.items.isEmpty {
            foundItemsSnapshot.append([.emptyStatePlaceholder(LString.titleNothingSuitableFound)])
        }
        appendEntryCreatorItem(to: &foundItemsSnapshot)
        self._items = .foundAutomatically(foundItemsSnapshot)
    }

    public func setContext(_ text: String?) {
        self._callerID = Item.autoFillContext(text ?? "")
    }

    private func appendEntryCreatorItem(to snapshot: inout SectionSnapshot) {
        guard delegate?.shouldAllowEntryCreation(in: self) == true else {
            return
        }
        let needsPremium = !PremiumManager.shared.isAvailable(feature: .canCreateEntriesInAutoFill)
        let entryCreatorItem = Item.entryCreator(needsPremium: needsPremium)
        snapshot.append([entryCreatorItem])
    }
}

extension EntryFinderVC {

    internal func _applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        if !_announcements.isEmpty {
            snapshot.appendSections([.announcements])
            snapshot.appendItems(_announcements, toSection: .announcements)
            snapshot.reconfigureItems(_announcements)
        }

        if !_recentEntrySection.items.isEmpty {
            snapshot.appendSections([.recentEntry])
        }

        var hasDataItems = false
        switch _items {
        case .overview(let allItemsSnapshot):
            hasDataItems = !allItemsSnapshot.items.isEmpty
            if hasDataItems {
                snapshot.appendSections([.allItems])
            }
        case .foundManually(let foundItemsSnapshot):
            hasDataItems = !foundItemsSnapshot.items.isEmpty
            if hasDataItems {
                snapshot.appendSections([.foundItems])
            }
        case .foundAutomatically(let foundItemsSnapshot):
            if foundItemsSnapshot.items.count > 0 {
                snapshot.appendSections([.foundItems])
                hasDataItems = true
            }
        }

        if let _callerID {
            snapshot.appendSections([.context])
            snapshot.appendItems([_callerID], toSection: .context)
        }
        _dataSource.apply(snapshot, animatingDifferences: true)

        if !_recentEntrySection.items.isEmpty {
            _dataSource.apply(_recentEntrySection, to: .recentEntry, animatingDifferences: false)
        }

        guard hasDataItems else {
            return
        }
        switch _items {
        case .overview(let allItemsSnapshot):
            if !allItemsSnapshot.items.isEmpty {
                _dataSource.apply(allItemsSnapshot, to: .allItems, animatingDifferences: true)
            }
        case .foundManually(let foundItemsSnapshot):
            if !foundItemsSnapshot.items.isEmpty {
                _dataSource.apply(foundItemsSnapshot, to: .foundItems, animatingDifferences: true)
            }
        case .foundAutomatically(let foundItemsSnapshot):
            if foundItemsSnapshot.items.count > 0 {
                _dataSource.apply(foundItemsSnapshot, to: .foundItems, animatingDifferences: true)
            }
        }
    }

    private func addGroupedItems(
        _ groupedItems: GroupedItems,
        kind: Item.Kind,
        to snapshot: inout SectionSnapshot,
        includeFields: Bool,
    ) {
        let groupItem = Item.group(groupedItems.group, kind)
        snapshot.append([groupItem])

        var itemsAdded = 0
        let entries = groupedItems.scoredItems.compactMap { $0.item as? Entry }
        if includeFields {
            entries.forEach {
                itemsAdded += appendEntryWithFields($0, kind: kind, to: &snapshot)
            }
        } else {
            let entryItems = entries.map { Item.entry($0, kind) }
            snapshot.append(entryItems)
            itemsAdded = entryItems.count
        }

        if itemsAdded == 0 {
            snapshot.delete([groupItem])
        }
    }

    @discardableResult
    private func appendEntryWithFields(
        _ entry: Entry,
        kind: Item.Kind,
        to snapshot: inout SectionSnapshot
    ) -> Int {
        guard #available(iOS 18, *) else {
            assertionFailure("appendEntryWithFields should not be called on iOS < 18")
            return 0
        }
        guard let selectableFields = delegate?.getSelectableFields(for: entry, in: self),
              !selectableFields.isEmpty
        else {
            return 0
        }
        let entryItem = EntryFinderVC.Item.entry(entry, kind)
        let fieldItems = selectableFields.map { EntryFinderVC.Item.field($0, entry, kind) }
        guard fieldItems.count > 0 else {
            return 0
        }
        snapshot.append([entryItem])
        snapshot.append(fieldItems, to: entryItem)
        return fieldItems.count
    }
}

extension EntryFinderVC {
    internal func _toggleExpanded(_ item: Item, kind: Item.Kind) {
        switch kind {
        case .recent:
            toggleExpanded(item, section: .recentEntry)
        case .exact, .standard:
            switch _items {
            case .overview:
                toggleExpanded(item, section: .allItems)
            case .foundManually:
                toggleExpanded(item, section: .foundItems)
            case .foundAutomatically:
                toggleExpanded(item, section: .foundItems)
            }
        }
    }

    private func toggleExpanded(_ item: Item, section: Section) {
        var snapshot = _dataSource.snapshot(for: section)
        guard snapshot.contains(item) else { return }
        if snapshot.isExpanded(item) {
            snapshot.collapse([item])
            _expandedItem = nil
        } else {
            snapshot.collapse(snapshot.items)
            snapshot.expand([item])
            _expandedItem = item
        }
        _dataSource.apply(snapshot, to: section)
    }
}

extension EntryFinderVC {
    func _getIndexPath(for entry: Entry) -> IndexPath? {
        switch _items {
        case .overview(let allItemsSnapshot):
            return find(entry.runtimeUUID, in: allItemsSnapshot)
        case .foundManually(let foundItemsSnapshot):
            return find(entry.runtimeUUID, in: foundItemsSnapshot)
        case .foundAutomatically(let foundItemsSnapshot):
            return find(entry.runtimeUUID, in: foundItemsSnapshot)
        }
    }

    private func find(_ runtimeUUID: UUID, in snapshot: SectionSnapshot) -> IndexPath? {
        let itemByUUID = snapshot.items.first(where: {
            if case let .entry(entry, _) = $0 {
                return entry.runtimeUUID == runtimeUUID
            }
            return false
        })
        if let itemByUUID {
            return _dataSource.indexPath(for: itemByUUID)
        }
        return nil
    }

    func _getFirstEntryIndexPath() -> IndexPath? {
        switch _items {
        case .overview(let allItemsSnapshot):
            return getRecentEntryIndexPath()
                ?? findFirstEntry(in: allItemsSnapshot)
        case .foundManually(let foundItemsSnapshot):
            return findFirstEntry(in: foundItemsSnapshot)
                ?? getRecentEntryIndexPath()
        case .foundAutomatically(let foundItemsSnapshot):
            return findFirstEntry(in: foundItemsSnapshot)
                ?? getRecentEntryIndexPath()
        }
    }

    private func findFirstEntry(in snapshot: SectionSnapshot) -> IndexPath? {
        let firstEntryItem = snapshot.items.first(where: {
            if case .entry = $0 {
                return true
            } else {
                return false
            }
        })
        if let firstEntryItem {
            return _dataSource.indexPath(for: firstEntryItem)
        }
        return nil
    }

    private func getRecentEntryIndexPath() -> IndexPath? {
        guard let recentEntryItem = _recentEntrySection.items.first else {
            return nil
        }
        return _dataSource.indexPath(for: recentEntryItem)
    }
}

extension EntryFinderVC {
    internal func _selectNextItem() {
        guard let selectedItem = _collectionView.indexPathsForSelectedItems?.first else {
            let firstSelectableIndexPath = _collectionView.indexPathsForVisibleItems
                .filter { _isSelectableCell(at: $0) }
                .min()
            _selectAndScrollToCell(at: firstSelectableIndexPath)
            return
        }
        guard let nextItem = nextSelectableIndexPath(from: selectedItem, direction: 1) else {
            return
        }
        _selectAndScrollToCell(at: nextItem)
    }

    internal func _selectPreviousItem() {
        guard let selectedItem = _collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        guard let previousItem = nextSelectableIndexPath(from: selectedItem, direction: -1) else {
            return
        }
        _selectAndScrollToCell(at: previousItem)
    }

    internal func _selectAndScrollToCell(at indexPath: IndexPath?) {
        guard let indexPath else { return }
        _collectionView.scrollToItem(at: indexPath, at: [.centeredVertically], animated: true)
        _collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }

    private func nextSelectableIndexPath(
        from current: IndexPath,
        direction: Int
    ) -> IndexPath? {
        assert(direction == 1 || direction == -1, "Unsupported direction")
        let snapshot = _dataSource.snapshot()
        let sections = snapshot.sectionIdentifiers

        guard current.section < sections.count else { return nil }
        let currentSectionID = sections[current.section]
        let itemsInCurrentSection = snapshot.itemIdentifiers(inSection: currentSectionID)

        guard current.item < itemsInCurrentSection.count else { return nil }

        var sectionIndex = current.section
        var itemIndex = current.item + direction

        while sectionIndex >= 0 && sectionIndex < sections.count {
            let sectionID = sections[sectionIndex]
            let items = snapshot.itemIdentifiers(inSection: sectionID)

            while itemIndex >= 0 && itemIndex < items.count {
                let ip = IndexPath(item: itemIndex, section: sectionIndex)
                let allowed = _isSelectableCell(at: ip)
                if allowed { return ip }
                itemIndex += direction
            }

            sectionIndex += direction
            if direction > 0 {
                itemIndex = 0
            } else if sectionIndex >= 0 {
                let newItems = snapshot.itemIdentifiers(inSection: sections[sectionIndex])
                itemIndex = newItems.count - 1
            }
        }
        return nil
    }
}
