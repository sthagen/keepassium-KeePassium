//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class EntryFinderFieldCell: SelectableCollectionViewListCell {
    typealias EntryFieldAndEntry = (field: EntryField, entry: Entry)

    static func makeRegistration() ->
        UICollectionView.CellRegistration<EntryFinderFieldCell, EntryFieldAndEntry>
    {
        return UICollectionView.CellRegistration<EntryFinderFieldCell, EntryFieldAndEntry> {
            cell, indexPath, item in
            cell.indentationWidth = 44
            cell.configure(field: item.field, of: item.entry)
        }
    }

    func configure(field: EntryField, of entry: Entry) {
        var config = UIListContentConfiguration.valueCell()
        config.text = field.visibleName
        if field.isProtected {
            config.secondaryText = EntryField.protectedValueMask
        } else {
            config.secondaryText = field.resolvedValue
        }
        config.textProperties.numberOfLines = 1
        config.textProperties.color = .secondaryLabel
        config.secondaryTextProperties.color = .label
        config.secondaryTextProperties.numberOfLines = 1
        config.secondaryTextProperties.lineBreakMode = .byTruncatingTail
        config.prefersSideBySideTextAndSecondaryText = true

        self.contentConfiguration = config
    }
}
