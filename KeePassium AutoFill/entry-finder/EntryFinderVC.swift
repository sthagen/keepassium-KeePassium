//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
import UIKit

final class EntryFinderVC: UIViewController {
    protocol Delegate: AnyObject {
        func didChangeSearchQuery(_ text: String, in viewController: EntryFinderVC)
        func didSelectEntry(_ entry: Entry, in viewController: EntryFinderVC)

        @available(iOS 18.0, *)
        func getSelectableFields(for entry: Entry, in viewController: EntryFinderVC) -> [EntryField]?

        @available(iOS 18.0, *)
        func didSelectField(_ field: EntryField, in entry: Entry, in viewController: EntryFinderVC)
    }

    weak var delegate: Delegate?

    let isFieldPickerMode: Bool

    internal var _dataSource: DataSource!
    internal let _itemDecorator: EntryFinderItemDecorator?
    internal let _toolbarDecorator: EntryFinderToolbarDecorator?

    internal var _announcements: [Item] = []
    internal var _recentEntrySection = SectionSnapshot()
    internal var _items: DataViewModel = .empty
    internal var _callerID: Item?
    internal var _expandedItem: Item?

    internal var _collectionView: UICollectionView!
    internal var _searchController: UISearchController!

    override var canBecomeFirstResponder: Bool { true }

    init(
        title: String?,
        includeFields: Bool,
        itemDecorator: EntryFinderItemDecorator?,
        toolbarDecorator: EntryFinderToolbarDecorator?,
    ) {
        self.isFieldPickerMode = includeFields
        self._itemDecorator = itemDecorator
        self._toolbarDecorator = toolbarDecorator
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .systemGroupedBackground
        let appearance: FilePickerAppearance = .insetGrouped
        _setupCollectionView(appearance: appearance)
        _setupDataSource(appearance: appearance)
        _setupSearch()
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    func refresh() {
        _applySnapshot()
        setupToolbar()
        setupNavbar()
    }

    private func setupToolbar() {
        let toolbarItems = _toolbarDecorator?.getToolbarItems()
        setToolbarItems(toolbarItems, animated: false)
    }

    private func setupNavbar() {
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leadingItemGroups = _toolbarDecorator?.getLeadingItemGroups() ?? []
        navigationItem.trailingItemGroups = _toolbarDecorator?.getTrailingItemGroups() ?? []
    }

    public func selectEntry(_ entry: Entry?, animated: Bool) {
        if let entry {
            guard let indexPath = _getIndexPath(for: entry) else {
                return
            }
            _collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
            return
        }

        _collectionView.selectItem(at: nil, animated: animated, scrollPosition: [])
    }
}
