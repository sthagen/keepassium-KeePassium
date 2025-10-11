//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryCreatorVC {
    typealias Appearance = UICollectionLayoutListConfiguration.Appearance

    func _setupCollectionView(appearance: Appearance) {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: appearance)
        layoutConfig.showsSeparators = false
        layoutConfig.backgroundColor = .clear
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        _collectionView.allowsSelection = false
        _collectionView.allowsFocus = true
        _collectionView.alwaysBounceVertical = false

        view.addSubview(_collectionView)
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            _collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    internal func _setupDataSource(appearance: Appearance) {
        let announcementCellRegistration = AnnouncementCollectionCell.makeRegistration(
            appearance: appearance
        )
        let fieldCellRegistration = makeFieldCellRegistration()
        let protectedFieldCellRegistration = makeProtectedFieldCellRegistration()
        let locationCellRegistration = makeLocationCellRegistration()

        _dataSource = DataSource(collectionView: _collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case .announcement(let announcement):
                return collectionView.dequeueConfiguredReusableCell(
                    using: announcementCellRegistration,
                    for: indexPath,
                    item: announcement)
            case let .entryField(fieldConfig):
                switch fieldConfig.kind {
                case .password:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: protectedFieldCellRegistration,
                        for: indexPath,
                        item: fieldConfig)
                default:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: fieldCellRegistration,
                        for: indexPath,
                        item: fieldConfig)
                }
            case let .location(group):
                return collectionView.dequeueConfiguredReusableCell(
                    using: locationCellRegistration,
                    for: indexPath,
                    item: group)
            }
        }
    }

    private func makeFieldCellRegistration()
        -> UICollectionView.CellRegistration<EntryCreatorFieldCell, EntryCreatorFieldConfiguration>
    {
        UICollectionView.CellRegistration<EntryCreatorFieldCell, EntryCreatorFieldConfiguration> {
            [weak self] cell, indexPath, fieldConfig in
            let actionMenu = self?._itemDecorator?.getActionMenu(for: fieldConfig.name)
            cell.configure(with: fieldConfig, actionMenu: actionMenu)
            cell.delegate = self
        }
    }

    private func makeProtectedFieldCellRegistration()
        -> UICollectionView.CellRegistration<EntryCreatorProtectedFieldCell, EntryCreatorFieldConfiguration>
    {
        UICollectionView.CellRegistration<EntryCreatorProtectedFieldCell, EntryCreatorFieldConfiguration> {
            [weak self] cell, indexPath, fieldConfig in
            let actionMenu = self?._itemDecorator?.getActionMenu(for: fieldConfig.name)
            cell.configure(with: fieldConfig, actionMenu: actionMenu)
            cell.delegate = self
        }
    }

    private func makeLocationCellRegistration()
        -> UICollectionView.CellRegistration<EntryCreatorLocationCell, Group>
    {
        UICollectionView.CellRegistration<EntryCreatorLocationCell, Group> {
            [weak self] cell, indexPath, group in
            let groupPickerMenu = self?._itemDecorator?.getGroupPickerMenu()
            cell.configure(with: group, menu: groupPickerMenu)
        }
    }
}
