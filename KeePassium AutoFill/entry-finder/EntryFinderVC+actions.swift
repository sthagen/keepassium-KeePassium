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
    override var keyCommands: [UIKeyCommand]? {
        let searchKey = UIKeyCommand(action: #selector(didPressSearch), hotkey: .search)

        let enterKey = UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(_didPressEnter))
        enterKey.wantsPriorityOverSystemBehavior = true

        let downArrowKey = UIKeyCommand(
            input: UIKeyCommand.inputDownArrow,
            modifierFlags: [],
            action: #selector(didPressDownKey))
        downArrowKey.wantsPriorityOverSystemBehavior = true

        let upArrowKey = UIKeyCommand(
            input: UIKeyCommand.inputUpArrow,
            modifierFlags: [],
            action: #selector(didPressUpKey))
        upArrowKey.wantsPriorityOverSystemBehavior = true

        return [searchKey, enterKey, downArrowKey, upArrowKey] + (super.keyCommands ?? [])
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        let firstKeyCode = presses.first?.key?.keyCode
        switch (presses.count, firstKeyCode) {
        case (1, .keyboardEscape):
            if _searchController.isActive && !ProcessInfo.isRunningOnMac {
                Diag.debug("Escape from search")
                _searchController.isActive = false
                return
            }
        default:
            break
        }
        super.pressesBegan(presses, with: event)
    }

    @objc private func didPressSearch() {
        activateManualSearch()
    }

    @objc private func didPressUpKey() {
        _selectPreviousItem()
    }

    @objc private func didPressDownKey() {
        _selectNextItem()
    }

    @objc internal func _didPressEnter() {
        if let selectedIndexPath = _collectionView.indexPathsForSelectedItems?.first {
            _handlePrimaryAction(at: selectedIndexPath, cause: .keyPress)
        } else {
            if let firstIndexPath = _getFirstEntryIndexPath() {
                _selectAndScrollToCell(at: firstIndexPath)
            }
        }
    }

    internal func _handlePrimaryAction(at indexPath: IndexPath, cause: ItemActivationCause?) {
        guard let selectedItem = _dataSource.itemIdentifier(for: indexPath) else {
            assertionFailure()
            return
        }
        switch selectedItem {
        case .announcement, .emptyStatePlaceholder, .group, .autoFillContext:
            assertionFailure("This item should not be selectable")
            return
        case let .entry(entry, kind):
            if isFieldPickerMode {
                _toggleExpanded(selectedItem, kind: kind)
            } else {
                delegate?.didSelectEntry(entry, in: self)
            }
        case let .field(field, entry, _):
            assert(isFieldPickerMode)
            guard #available(iOS 18, *) else { assertionFailure(); return }
            delegate?.didSelectField(field, in: entry, in: self)
        }
    }
}
