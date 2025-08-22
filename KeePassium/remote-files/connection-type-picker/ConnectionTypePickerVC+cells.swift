//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension ConnectionTypePickerVC {
    internal func _setupCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        config.footerMode = .supplementary
        config.showsSeparators = true
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        _collectionView.backgroundColor = .clear
        _collectionView.alwaysBounceVertical = false
        _collectionView.allowsFocus = true
        _collectionView.allowsSelection = true
        _collectionView.selectionFollowsFocus = true
        _collectionView.delegate = self

        view.addSubview(_collectionView)
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            _collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    internal func _setupDataSource() {
        let cellReg = UICollectionView.CellRegistration<SelectableCollectionViewListCell, Item> {
            [weak self] cell, indexPath, item in
            guard let self else { return }

            cell.accessibilityTraits = [.button]
            switch item {
            case let .service(service, status):
                configureServiceCell(
                    cell,
                    service: service,
                    status: status
                )
            case let .remoteConnection(connectionType, status):
                configureConnectionTypeCell(
                    cell,
                    connectionType: connectionType,
                    status: status
                )
            case let .systemPicker(status):
                configureSystemPickerCell(cell, status: status)
            }
        }

        _dataSource = DataSource(collectionView: _collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellReg, for: indexPath, item: item)
        }

        let headerCellRegistration = makeHeaderCellRegistration()
        let footerCellRegistration = makeFooterCellRegistration()
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
}

extension ConnectionTypePickerVC {
    private func configureServiceCell(
        _ cell: SelectableCollectionViewListCell,
        service: RemoteConnectionType.Service,
        status: Item.Status
    ) {
        let isEnabled = status.isAllowed && !status.isBusy
        var content = UIListContentConfiguration.cell()
        var accessories = [UICellAccessory]()
        content.text = service.description
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.image = .symbol(service.iconSymbol)

        if status.isAllowed {
            accessories.append(.outlineDisclosure(options: .init(
                tintColor: isEnabled ? .systemTint : .disabledText
            )))
        } else {
            content.secondaryText = LString.Error.storageAccessDeniedByOrg
        }
        if isEnabled {
            content.imageProperties.tintColor = .systemTint
            content.textProperties.color = .label
            content.secondaryTextProperties.color = .secondaryLabel
        } else {
            content.imageProperties.tintColor = .disabledText
            content.textProperties.color = .disabledText
            content.secondaryTextProperties.color = .disabledText
            cell.accessibilityTraits.insert(.notEnabled)
        }
        cell.contentConfiguration = content

        if status.needsPremium {
            accessories.append(.premiumFeatureIndicator())
        }
        cell.accessories = accessories
    }

    private func configureConnectionTypeCell(
        _ cell: SelectableCollectionViewListCell,
        connectionType: RemoteConnectionType,
        status: Item.Status
    ) {
        var content = UIListContentConfiguration.cell()
        if status.isAllowed {
            content.text = connectionType.description
            content.secondaryText = connectionType.subtitle
        } else {
            let title = [connectionType.description, connectionType.subtitle]
                .compactMap { $0 }
                .joined(separator: " — ")
            content.text = title
            content.secondaryText = LString.Error.storageAccessDeniedByOrg
        }
        content.textProperties.font = .preferredFont(forTextStyle: .body)
        content.image = .symbol(connectionType.fileProvider.iconSymbol)
        let isEnabled = status.isAllowed && !status.isBusy
        if isEnabled {
            content.textProperties.color = .label
            content.secondaryTextProperties.color = .secondaryLabel
            content.imageProperties.tintColor = .systemTint
        } else {
            content.textProperties.color = .disabledText
            content.secondaryTextProperties.color = .disabledText
            content.imageProperties.tintColor = .disabledText
            cell.accessibilityTraits.insert(.notEnabled)
        }
        cell.contentConfiguration = content
        cell.indentationWidth = ProcessInfo.isRunningOnMac ? 44 : 20

        var accessories: [UICellAccessory] = []
        if status.needsPremium {
            accessories.append(.premiumFeatureIndicator())
        } else {
            accessories.append(.disclosureIndicator())
        }
        cell.accessories = accessories
    }

    private func configureSystemPickerCell(_ cell: SelectableCollectionViewListCell, status: Item.Status) {
        var content = UIListContentConfiguration.cell()
        content.text = LString.connectionTypeOtherLocations
        if !status.isAllowed {
            content.secondaryText = LString.Error.storageAccessDeniedByOrg
        }
        let isEnabled = status.isAllowed && !status.isBusy
        if isEnabled {
            content.textProperties.color = .label
            content.secondaryTextProperties.color = .secondaryLabel
        } else {
            content.textProperties.color = .disabledText
            content.secondaryTextProperties.color = .disabledText
            cell.accessibilityTraits.insert(.notEnabled)
        }
        cell.contentConfiguration = content
        cell.accessories = [.disclosureIndicator()]
    }

    private func makeHeaderCellRegistration() ->
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
    {
        return UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) {
            [weak self] supplementaryView, elementKind, indexPath in
            guard let self else { return }
            var content = supplementaryView.defaultContentConfiguration()
            switch _dataSource.sectionIdentifier(for: indexPath.section) {
            case let .remoteConnections(header, _):
                content.text = header
            case let .otherLocations(header, _):
                content.text = header
            case .none:
                assertionFailure()
            }
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
            guard let self else { return }
            var content = supplementaryView.defaultContentConfiguration()
            switch _dataSource.sectionIdentifier(for: indexPath.section) {
            case let .remoteConnections(_, footer):
                content.text = footer
            case let .otherLocations(_, footer):
                content.text = footer
            case .none:
                assertionFailure()
            }
            supplementaryView.contentConfiguration = content
        }
    }
}
