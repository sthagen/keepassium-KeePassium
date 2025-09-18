//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class GroupViewerDataSource: UICollectionViewDiffableDataSource<GroupViewerVC.Section, GroupViewerItem> {
    let nonLettersKey = "#"
    private var sortedKeyLetters: [String] = []
    private var index: [String: IndexPath] = [:]

    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        switch Settings.current.groupSortOrder {
        case .noSorting,
             .creationTimeAsc,
             .creationTimeDesc,
             .modificationTimeAsc,
             .modificationTimeDesc:
            return nil
        case .nameAsc, .nameDesc:
            break
        }

        sortedKeyLetters.removeAll()
        index.removeAll()
        let items = snapshot().itemIdentifiers
        for item in items {
            switch item {
            case .announcement, .emptyStatePlaceholder, .group:
                continue
            case .entry(let entry):
                let indexKey = toIndexKey(entry.resolvedTitle.first)
                if index[indexKey] == nil {
                    sortedKeyLetters.append(indexKey)
                    index[indexKey] = self.indexPath(for: item)
                }
            }
        }
        return sortedKeyLetters
    }

    private func toIndexKey(_ symbol: Character?) -> String {
        switch symbol {
        case .some(let c) where c.isLetter:
            return String(c)
        default:
            return "#"
        }
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        indexPathForIndexTitle title: String,
        at index: Int
    ) -> IndexPath {
        guard let result = self.index[title] else {
            assertionFailure("Unexpected index title")
            return IndexPath(item: 0, section: 0)
        }
        return result
    }
}
