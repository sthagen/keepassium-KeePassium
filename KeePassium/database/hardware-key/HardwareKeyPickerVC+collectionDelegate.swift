//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension HardwareKeyPickerVC: UICollectionViewDelegate {
    private func isSelectableCell(at indexPath: IndexPath) -> Bool {
        switch _dataSource.itemIdentifier(for: indexPath) {
        case .noKey, .infoLink:
            return true
        case .keyType(let keyTypeInfo):
            return keyTypeInfo.isEnabled
        case .keySlot(let keySlotInfo):
            return keySlotInfo.keyType.isEnabled
        case .none:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return isSelectableCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return isSelectableCell(at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        canPerformPrimaryActionForItemAt indexPath: IndexPath
    ) -> Bool {
        return isSelectableCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performPrimaryActionForItemAt indexPath: IndexPath
    ) {
        _handlePrimaryAction(at: indexPath, cause: .touch)
    }

    internal func _handlePrimaryAction(at indexPath: IndexPath, cause: ItemActivationCause?) {
        guard let selectedItem = _dataSource.itemIdentifier(for: indexPath) else {
            assertionFailure()
            return
        }
        if cause == .touch {
            _collectionView.deselectItem(at: indexPath, animated: true)
        }

        switch selectedItem {
        case .noKey:
            delegate?.didSelectKey(nil, in: self)
        case .keyType:
            guard let section = _dataSource.sectionIdentifier(for: indexPath.section) else {
                assertionFailure()
                return
            }
            toggleExpanded(selectedItem, in: section)
        case .keySlot(let slotInfo):
            delegate?.didSelectKey(slotInfo.asHardwareKey, in: self)
        case .infoLink:
            delegate?.didPressLearnMore(in: self)
        }
    }

    private func toggleExpanded(_ item: Item, in section: HardwareKeyPickerSection) {
        var sectionSnapshot = _dataSource.snapshot(for: section)
        if sectionSnapshot.isExpanded(item) {
            sectionSnapshot.collapse([item])
            _expandedItems.remove(item)
        } else {
            sectionSnapshot.expand([item])
            _expandedItems.insert(item)
        }
        _dataSource.apply(sectionSnapshot, to: section)
    }
}
