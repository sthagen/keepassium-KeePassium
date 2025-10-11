//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class GroupViewerGroupCell: SelectableCollectionViewListCell {

    func configure(with group: Group, accessories: [UICellAccessory]?) {
        var config = UIListContentConfiguration.valueCell()
        config.text = group.name
        config.textProperties.numberOfLines = 3
        config.textProperties.font = .preferredFont(forTextStyle: .headline)

        let childrenCount = group.groups.count + group.entries.count
        if !group.isSmartGroup {
            config.secondaryText = String(childrenCount)
        }
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 1

        config.image = UIImage.kpIcon(forGroup: group)
        config.imageProperties.maximumSize = UIImage.kpIconMaxSize
        self.contentConfiguration = config

        UIView.performWithoutAnimation { [weak self] in
            self?.accessories = accessories ?? []
        }

        if group.isSmartGroup {
            accessibilityLabel = String.localizedStringWithFormat(
                LString.titleSmartGroupDescriptionTemplate,
                group.name)
            accessibilityValue = nil
        } else {
            accessibilityLabel = String.localizedStringWithFormat(
                LString.titleGroupDescriptionTemplate,
                group.name)
            accessibilityValue = String.localizedStringWithFormat(
                LString.itemsCountTemplate,
                childrenCount)
        }
    }
}
