//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension HardwareKeyPickerVC {
    internal func _setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let section = self?._sections[sectionIndex] else { return nil }

            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = (section.header == nil && sectionIndex != 0) ? .none : .supplementary
            config.footerMode = section.footer == nil ? .none : .supplementary

            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        _collectionView.delegate = self
        _collectionView.backgroundColor = .clear
        _collectionView.allowsSelection = true
        _collectionView.allowsFocus = true
        _collectionView.selectionFollowsFocus = true

        view.addSubview(_collectionView)
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            _collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            _collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            _collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    internal func _setupDataSource() {
        let noKeyCellRegistration = makeNoKeyCellRegistration()
        let keyCellRegistration = makeKeyTypeCellRegistration()
        let slotCellRegistration = makeKeySlotCellRegistration()
        let infoCellRegistration = makeInfoCellRegistration()

        _dataSource = UICollectionViewDiffableDataSource(collectionView: _collectionView) {
            collectionView, indexPath, item in
            switch item {
            case .noKey:
                return collectionView.dequeueConfiguredReusableCell(
                    using: noKeyCellRegistration,
                    for: indexPath,
                    item: LString.noHardwareKey
                )
            case .keyType(let keyTypeInfo):
                return collectionView.dequeueConfiguredReusableCell(
                    using: keyCellRegistration,
                    for: indexPath,
                    item: keyTypeInfo
                )
            case .keySlot(let keySlotInfo):
                return collectionView.dequeueConfiguredReusableCell(
                    using: slotCellRegistration,
                    for: indexPath,
                    item: keySlotInfo
                )
            case .infoLink(let text):
                return collectionView.dequeueConfiguredReusableCell(
                    using: infoCellRegistration,
                    for: indexPath,
                    item: text
                )
            }
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

extension HardwareKeyPickerVC {
    private func makeNoKeyCellRegistration() ->
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, String>
    {
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, String> {
            [weak self] cell, indexPath, title in
            guard let self else { return }

            cell.accessibilityTraits = []
            var content = UIListContentConfiguration.cell()
            content.text = title
            cell.contentConfiguration = content

            if selectedKey == nil {
                cell.accessories = [.checkmark()]
                cell.accessibilityTraits.insert(.selected)
                _focusTargetCell = cell
            } else {
                cell.accessories = []
            }
            cell.accessibilityTraits.insert(.button)
        }
    }

    private func makeKeyTypeCellRegistration() ->
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, Item.KeyTypeInfo>
    {
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, Item.KeyTypeInfo> {
            [weak self] cell, indexPath, keyTypeInfo in
            guard let self else { return }

            let isEnabled = keyTypeInfo.isEnabled
            cell.accessibilityTraits = []
            var content = UIListContentConfiguration.valueCell()
            content.text = keyTypeInfo.localizedDescription
            content.textProperties.color = isEnabled ? .label : .disabledText
            if let selectedKey,
               keyTypeInfo.kind == selectedKey.kind,
               keyTypeInfo.interface == selectedKey.interface
            {
                content.secondaryText = selectedKey.slot.localizedDescription
                content.secondaryTextProperties.color = .secondaryLabel
            }
            cell.contentConfiguration = content

            cell.accessories = []
            if keyTypeInfo.needsPremium {
                cell.accessories.append(.premiumFeatureIndicator())
                cell.accessibilityValue = LString.premiumFeatureGenericTitle
            }
            cell.accessories.append(
                .outlineDisclosure(options: .init(
                    style: .automatic,
                    tintColor: isEnabled ? .secondaryLabel : .disabledText
                ))
            )

            cell.isUserInteractionEnabled = isEnabled
            cell.accessibilityTraits.insert(.button)
            if !isEnabled {
                cell.accessibilityTraits.insert(.notEnabled)
            }
        }
    }

    private func makeKeySlotCellRegistration() ->
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, Item.KeySlotInfo>
    {
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, Item.KeySlotInfo> {
            [weak self] cell, indexPath, keySlotInfo in
            guard let self else { return }

            let isEnabled = keySlotInfo.keyType.isEnabled

            cell.accessibilityTraits = []
            var content = UIListContentConfiguration.cell()
            content.text = String.localizedStringWithFormat(
                LString.hardwareKeySlotNTemplate,
                keySlotInfo.keyType.kind.description,
                keySlotInfo.slot.rawValue
            )
            content.textProperties.color = isEnabled ? .label : .disabledText
            cell.contentConfiguration = content

            cell.accessories = []
            if keySlotInfo.keyType.needsPremium {
                cell.accessories.append(.premiumFeatureIndicator())
                cell.accessibilityValue = LString.premiumFeatureGenericTitle
            }
            if keySlotInfo.asHardwareKey == selectedKey {
                cell.accessories.append(.checkmark())
                cell.accessibilityTraits.insert(.selected)
                _focusTargetCell = cell
            }
            cell.indentationWidth = ProcessInfo.isRunningOnMac ? 44 : 24
            cell.indentsAccessories = true

            cell.isUserInteractionEnabled = isEnabled
            cell.accessibilityTraits.insert(.button)
            if !isEnabled {
                cell.accessibilityTraits.insert(.notEnabled)
            }
        }
    }

    private func makeInfoCellRegistration() ->
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, String>
    {
        UICollectionView.CellRegistration<SelectableCollectionViewListCell, String> {
            cell, indexPath, text in
            var content = UIListContentConfiguration.cell()
            content.text = text
            content.textProperties.color = .link
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            cell.accessibilityTraits.insert(.link)
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
            content.text = section.header
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
            content.text = section.footer
            supplementaryView.contentConfiguration = content
        }
    }
}
