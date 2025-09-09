//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class GroupViewerEntryCell: SelectableCollectionViewListCell {

    func configure(with entry: Entry, accessories: [UICellAccessory]?) {
        var config = UIListContentConfiguration.cell()
        config.text = entry.resolvedTitle
        config.textProperties.numberOfLines = 1
        config.textProperties.font = .preferredFont(forTextStyle: .body)

        config.secondaryText = entry.resolvedSubtitle
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 1

        config.image = UIImage.kpIcon(forEntry: entry)
        config.imageProperties.maximumSize = UIImage.kpIconMaxSize
        self.contentConfiguration = config

        UIView.performWithoutAnimation { [weak self] in
            self?.accessories = accessories ?? []
        }
    }
}
