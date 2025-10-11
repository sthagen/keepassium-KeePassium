//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class EntryCreatorLocationCell: SelectableCollectionViewListCell {
    func configure(with group: Group, menu: UIMenu?) {
        var breadcrumbs = [String]()
        var currentGroup: Group? = group
        while let aGroup = currentGroup {
            breadcrumbs.append(aGroup.name)
            currentGroup = aGroup.parent
        }

        var config = UIListContentConfiguration.subtitleCell()
        config.text = LString.titleEntryLocation
        config.textProperties.color = .secondaryLabel
        config.textProperties.numberOfLines = 1
        config.textProperties.lineBreakMode = .byTruncatingTail
        config.textProperties.font = .preferredFont(forTextStyle: .subheadline)

        config.secondaryText = breadcrumbs.reversed().joined(separator: " › ")
        config.secondaryTextProperties.color = .primaryText
        config.secondaryTextProperties.numberOfLines = 2
        config.secondaryTextProperties.lineBreakMode = .byTruncatingHead
        config.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)

        config.prefersSideBySideTextAndSecondaryText = false
        config.textToSecondaryTextVerticalPadding = 8
        config.textToSecondaryTextHorizontalPadding = 16
        config.directionalLayoutMargins = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        self.contentConfiguration = config

        if let menu {
            accessories = [.popUpMenu(menu, options: .init(isHidden: false, tintColor: .systemTint))]
        } else {
            accessories = []
        }
    }

}
