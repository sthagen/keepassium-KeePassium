//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class EntryFinderEntryCell: SelectableCollectionViewListCell {

    private weak var decorator: EntryFinderItemDecorator?
    private var fixedAccessories = [UICellAccessory]()

    static func makeRegistration(
        decorator: EntryFinderItemDecorator?
    ) -> UICollectionView.CellRegistration<EntryFinderEntryCell, Entry> {
        UICollectionView.CellRegistration<EntryFinderEntryCell, Entry> {
            [weak decorator] cell, indexPath, entry in
            let accessories = decorator?.getAccessories(for: entry)
            cell.configure(with: entry, accessories: accessories)
        }
    }

    func configure(with entry: Entry, accessories: [UICellAccessory]?) {
        var config = UIListContentConfiguration.cell()
        config.text = entry.resolvedTitle
        config.textProperties.numberOfLines = 1

        config.secondaryText = entry.resolvedSubtitle
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 1

        config.image = UIImage.kpIcon(forEntry: entry)
        config.imageProperties.maximumSize = UIImage.kpIconMaxSize
        self.contentConfiguration = config

        self.accessories = accessories ?? []
    }
}
