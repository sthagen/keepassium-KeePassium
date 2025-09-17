//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryCreatorVC: EntryCreatorFieldCell.Delegate {
    func didChangeText(_ newText: String, in fieldName: String) {
        delegate?.didChangeValue(of: fieldName, to: newText, in: self)
    }

    func didPressEnter(in fieldName: String) {
        delegate?.didPressDone(in: self)
    }

    func didChangeVisibility(of fieldName: String, isHidden: Bool) {
        delegate?.didChangeVisibility(of: fieldName, isHidden: isHidden, in: self)
    }
}
