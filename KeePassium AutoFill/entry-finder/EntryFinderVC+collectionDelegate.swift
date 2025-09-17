//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
import UIKit

extension EntryFinderVC: UICollectionViewDelegate {
    internal func _isSelectableCell(at indexPath: IndexPath) -> Bool {
        switch _dataSource.itemIdentifier(for: indexPath) {
        case .announcement, .emptyStatePlaceholder, .group, .autoFillContext:
            return false
        case .entryCreator, .entry, .field:
            return true
        case .none:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return _isSelectableCell(at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        return _isSelectableCell(at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        canPerformPrimaryActionForItemAt indexPath: IndexPath
    ) -> Bool {
        return _isSelectableCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performPrimaryActionForItemAt indexPath: IndexPath
    ) {
        _handlePrimaryAction(at: indexPath, cause: .touch)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        switch _dataSource.itemIdentifier(for: indexPath) {
        case .announcement, .entryCreator, .emptyStatePlaceholder, .group, .autoFillContext:
            return nil
        case let .entry(entry, _):
            guard let popoverAnchor = _collectionView.cellForItem(at: indexPath)?.asPopoverAnchor else {
                assertionFailure()
                return nil
            }
            return UIContextMenuConfiguration(actionProvider: { [weak _itemDecorator] _ in
                _itemDecorator?.getContextMenu(for: entry, at: popoverAnchor)
            })
        case .field:
            return nil
        case .none:
            assertionFailure()
            return nil
        }
    }
}
