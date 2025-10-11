//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class EntryCreatorVC: UIViewController {
    protocol Delegate: AnyObject {
        func didChangeValue(of fieldName: String, to newValue: String, in viewController: EntryCreatorVC)
        func didChangeVisibility(of fieldName: String, isHidden: Bool, in viewController: EntryCreatorVC)
        func didPressDone(in viewController: EntryCreatorVC)
    }

    weak var delegate: Delegate?

    var _dataSource: DataSource!
    let _itemDecorator: EntryCreatorItemDecorator?
    let _toolbarDecorator: EntryCreatorToolbarDecorator?
    var _announcements: [Item] = []
    var _entryFields: [Item] = []
    var _locationItems: [Item] = []

    var _collectionView: UICollectionView!

    private var isInitialFocusSet = false

    init(
        itemDecorator: EntryCreatorItemDecorator?,
        toolbarDecorator: EntryCreatorToolbarDecorator?
    ) {
        self._itemDecorator = itemDecorator
        self._toolbarDecorator = toolbarDecorator
        super.init(nibName: nil, bundle: nil)

        self.title = LString.titleNewEntry
        view.backgroundColor = .systemBackground
        let appearance = Appearance.plain
        _setupCollectionView(appearance: appearance)
        _setupDataSource(appearance: appearance)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isInitialFocusSet {
            setFirstResponderField(EntryField.title)
            isInitialFocusSet = true
        }
    }

    func refresh(animated: Bool) {
        _applySnapshot(animated: animated)
        updateToolbars(animated: animated)
    }

    func updateToolbars(animated: Bool) {
        let toolbarItems = _toolbarDecorator?.getToolbarItems()
        setToolbarItems(toolbarItems, animated: animated)

        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.setLeftBarButtonItems(
            _toolbarDecorator?.getLeftBarButtonItems(),
            animated: animated)
        navigationItem.setRightBarButtonItems(
            _toolbarDecorator?.getRightBarButtonItems(),
            animated: animated)
    }
}

extension EntryCreatorVC {
    func setFirstResponderField(_ fieldName: String) {
        let titleIndexPath = _collectionView.indexPathsForVisibleItems.first(where: {
            if case .entryField(let field) = _dataSource.itemIdentifier(for: $0) {
                return field.name == fieldName
            }
            return false
        })
        if let titleIndexPath,
           let titleCell = _collectionView.cellForItem(at: titleIndexPath)
        {
            titleCell.becomeFirstResponder()
        }
    }

    func accessibilityFocusLocation() {
        accessibilityFocus {
            if case .location = _dataSource.itemIdentifier(for: $0) {
                return true
            } else {
                return false
            }
        }
    }

    private func accessibilityFocus(_ filter: (IndexPath) -> Bool) {
        if let targetIndexPath = _collectionView.indexPathsForVisibleItems.first(where: filter),
           let targetCell = _collectionView.cellForItem(at: targetIndexPath)
        {
            UIAccessibility.post(notification: .screenChanged, argument: targetCell)
        }
    }
}
