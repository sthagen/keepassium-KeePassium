//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
import UIKit

final class HardwareKeyPickerVC: UIViewController {
    typealias Item = HardwareKeyPickerItem
    typealias DataSource = UICollectionViewDiffableDataSource<HardwareKeyPickerSection, Item>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>

    protocol Delegate: AnyObject {
        func didSelectKey(_ hardwareKey: HardwareKey?, in viewController: HardwareKeyPickerVC)
        func didPressLearnMore(in viewController: HardwareKeyPickerVC)
    }

    weak var delegate: Delegate?
    var selectedKey: HardwareKey? {
        didSet {
            guard isViewLoaded else { return }
            _updateSnapshot(animated: false)
            UIAccessibility.post(notification: .layoutChanged, argument: _focusTargetCell)
        }
    }

    internal var _dataSource: DataSource!
    internal var _collectionView: UICollectionView!
    internal var _sections: [HardwareKeyPickerSection] = []
    internal var _expandedItems: Set<Item> = []
    internal weak var _focusTargetCell: UICollectionViewCell?

    override var canBecomeFirstResponder: Bool { true }
    override var preferredFocusEnvironments: [any UIFocusEnvironment] {
        _focusTargetCell == nil ? [] : [_focusTargetCell!]
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        title = LString.titleHardwareKeys
        view.backgroundColor = .systemGroupedBackground

        _setupCollectionView()
        _setupDataSource()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _focusTargetCell {
            DispatchQueue.main.async {
                UIAccessibility.post(notification: .screenChanged, argument: _focusTargetCell)
            }
            setNeedsFocusUpdate()
            updateFocusIfNeeded()
        }
    }

    func update(with sections: [HardwareKeyPickerSection]) {
        self._sections = sections
        _updateSnapshot(animated: false)
    }
}

extension HardwareKeyPickerVC {
    internal func _updateSnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<HardwareKeyPickerSection, Item>()
        snapshot.appendSections(_sections)
        _dataSource.apply(snapshot, animatingDifferences: false)

        for section in _sections {
            var sectionSnapshot = SectionSnapshot()
            for item in section.items {
                switch item {
                case .noKey:
                    sectionSnapshot.append([item])
                case .keyType(let keyTypeInfo):
                    sectionSnapshot.append([item])
                    for slot in keyTypeInfo.availableSlots {
                        let slotInfo = Item.KeySlotInfo(keyType: keyTypeInfo, slot: slot)
                        sectionSnapshot.append([Item.keySlot(slotInfo)], to: item)
                    }
                    let isCurrent = keyTypeInfo.kind == selectedKey?.kind
                            && keyTypeInfo.interface == selectedKey?.interface
                    if isCurrent || _expandedItems.contains(item) {
                        sectionSnapshot.expand([item])
                    }
                case .keySlot:
                    assertionFailure("Unexpected item")
                case .infoLink:
                    sectionSnapshot.append([item])
                }
            }
            _dataSource.apply(sectionSnapshot, to: section, animatingDifferences: animated)
        }
    }
}

extension HardwareKeyPickerVC {
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(didPressEnter)),
        ]
    }

    @objc private func didPressEnter() {
        guard let selectedIndexPath = _collectionView.indexPathsForSelectedItems?.first else { return }
        _handlePrimaryAction(at: selectedIndexPath, cause: .keyPress)
    }
}
