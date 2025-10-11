//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class EntryFinderGroupCell: SelectableCollectionViewListCell {
    static func makeRegistration() -> UICollectionView.CellRegistration<EntryFinderGroupCell, Group> {
        UICollectionView.CellRegistration<EntryFinderGroupCell, Group> {
            cell, indexPath, group in
            cell.configure(with: group)
        }
    }

    func configure(with group: Group) {
        var breadcrumbs = [String]()
        var currentGroup: Group? = group
        while let aGroup = currentGroup {
            breadcrumbs.append(aGroup.name)
            currentGroup = aGroup.parent
        }

        var config = UIListContentConfiguration.plainHeader()
        config.text = breadcrumbs.reversed().joined(separator: " › ")
        config.textProperties.color = .secondaryLabel
        config.textProperties.numberOfLines = 1
        config.textProperties.lineBreakMode = .byTruncatingHead
        config.textProperties.font = .preferredFont(forTextStyle: .subheadline)
        self.contentConfiguration = config
        self.accessibilityHint = LString.titleGroup
    }
}
