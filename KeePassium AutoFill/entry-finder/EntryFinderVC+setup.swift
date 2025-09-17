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

    internal func _setupCollectionView(appearance: FilePickerAppearance) {
        let trailingActionsProvider = { [weak self] (indexPath: IndexPath) -> UISwipeActionsConfiguration? in
            guard let self else { return nil }
            switch _dataSource.itemIdentifier(for: indexPath) {
            case .announcement, .entryCreator, .emptyStatePlaceholder, .group, .autoFillContext:
                return nil
            case let .entry(entry, _):
                if let actions = _itemDecorator?.getTrailingSwipeActions(for: entry) {
                    return UISwipeActionsConfiguration(actions: actions)
                }
                return nil
            case .field:
                return nil
            case .none:
                assertionFailure()
                return nil
            }
        }
        let leadingActionsProvider = { [weak self] (indexPath: IndexPath) -> UISwipeActionsConfiguration? in
            guard let self else { return nil }
            switch _dataSource.itemIdentifier(for: indexPath) {
            case .announcement, .entryCreator, .emptyStatePlaceholder, .group, .autoFillContext:
                return nil
            case .entry(let entry, _):
                if let actions = _itemDecorator?.getLeadingSwipeActions(for: entry) {
                    return UISwipeActionsConfiguration(actions: actions)
                }
                return nil
            case .field:
                return nil
            case .none:
                assertionFailure()
                return nil
            }
        }

        var layoutConfig = UICollectionLayoutListConfiguration(appearance: appearance)
        layoutConfig.headerMode = .supplementary
        layoutConfig.footerMode = .supplementary
        layoutConfig.leadingSwipeActionsConfigurationProvider = leadingActionsProvider
        layoutConfig.trailingSwipeActionsConfigurationProvider = trailingActionsProvider
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        _collectionView.allowsSelection = true
        _collectionView.allowsFocus = true
        _collectionView.selectionFollowsFocus = true
        _collectionView.delegate = self

        view.addSubview(_collectionView)

        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            _collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    internal func _setupDataSource(appearance: FilePickerAppearance) {
        let announcementCellRegistration = AnnouncementCollectionCell.makeRegistration(
            appearance: appearance
        )
        let entryCreatorCellRegistration = makeEntryCreatorCellRegistration()
        let placeholderCellRegistration = makePlaceholderCellRegistration()
        let groupCellRegistration = EntryFinderGroupCell.makeRegistration()
        let entryCellRegistration = EntryFinderEntryCell.makeRegistration(decorator: _itemDecorator)
        let fieldCellRegistration = EntryFinderFieldCell.makeRegistration()
        let contextCellRegistration = AutoFillContextCell.makeRegistration()
        let headerCellRegistration = makeHeaderCellRegistration()
        let footerCellRegistration = makeFooterCellRegistration()

        _dataSource = DataSource(collectionView: _collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case .announcement(let announcement):
                return collectionView.dequeueConfiguredReusableCell(
                    using: announcementCellRegistration,
                    for: indexPath,
                    item: announcement)
            case .entryCreator(let needsPremium):
                return collectionView.dequeueConfiguredReusableCell(
                    using: entryCreatorCellRegistration,
                    for: indexPath,
                    item: needsPremium)
            case .emptyStatePlaceholder(let text):
                return collectionView.dequeueConfiguredReusableCell(
                    using: placeholderCellRegistration,
                    for: indexPath,
                    item: text)
            case .group(let group):
                return collectionView.dequeueConfiguredReusableCell(
                    using: groupCellRegistration,
                    for: indexPath,
                    item: group)
            case let .entry(entry, _):
                return collectionView.dequeueConfiguredReusableCell(
                    using: entryCellRegistration,
                    for: indexPath,
                    item: entry)
            case let .field(field, entry, _):
                return collectionView.dequeueConfiguredReusableCell(
                    using: fieldCellRegistration,
                    for: indexPath,
                    item: (field, entry))
            case .autoFillContext(let text):
                return collectionView.dequeueConfiguredReusableCell(
                    using: contextCellRegistration,
                    for: indexPath,
                    item: text)
            }
        }
        _dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerCellRegistration,
                    for: indexPath)
            case UICollectionView.elementKindSectionFooter:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: footerCellRegistration,
                    for: indexPath)
            default:
                return nil
            }
        }
    }

    private func makeEntryCreatorCellRegistration() ->
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, Bool>
    {
        return UICollectionView.CellRegistration<SelectableCollectionViewListCell, Bool> {
            cell, indexPath, needsPremium in
            var content = UIListContentConfiguration.cell()
            content.text = LString.actionCreateEntry
            content.textProperties.color = .actionTint
            content.image = .symbol(.plus)
            content.imageProperties.reservedLayoutSize = EntryFinderEntryCell.reservedImageSize
            cell.contentConfiguration = content
            cell.accessibilityTraits.insert(.button)
            cell.accessories = needsPremium ? [.premiumFeatureIndicator()] : []
        }
    }

    private func makePlaceholderCellRegistration() ->
        UICollectionView.CellRegistration<UICollectionViewListCell, String>
    {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> {
            cell, indexPath, value in
            var content = UIListContentConfiguration.cell()
            content.text = value
            content.textProperties.color = .secondaryLabel
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
        }
    }

    private func makeHeaderCellRegistration() ->
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
    {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) {
            [weak self] supplementaryView, elementKind, indexPath in
            var content = supplementaryView.defaultContentConfiguration()
            guard let section = self?._dataSource.sectionIdentifier(for: indexPath.section) else {
                assertionFailure()
                return
            }
            content.text = section.headerTitle
            supplementaryView.contentConfiguration = content
        }
    }

    private func makeFooterCellRegistration() ->
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
    {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) {
            [weak self] supplementaryView, elementKind, indexPath in
            var content = supplementaryView.defaultContentConfiguration()
            guard let section = self?._dataSource.sectionIdentifier(for: indexPath.section) else {
                assertionFailure()
                return
            }
            content.text = section.footerText
            supplementaryView.contentConfiguration = content
        }
    }
}
