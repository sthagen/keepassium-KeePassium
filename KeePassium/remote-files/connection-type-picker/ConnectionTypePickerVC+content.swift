//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension ConnectionTypePickerVC {
    internal func _isConnectionAllowed(_ connectionType: RemoteConnectionType) -> Bool {
        connectionType.fileProvider.isAllowed
    }

    internal func _isConnectionEnabled(_ connectionType: RemoteConnectionType) -> Bool {
        return !_isBusy && _isConnectionAllowed(connectionType)
    }

    internal func _isSelectableCell(at indexPath: IndexPath) -> Bool {
        switch _dataSource.itemIdentifier(for: indexPath) {
        case let .service(_, status):
            return status.isAllowed && !status.isBusy
        case let .remoteConnection(_, status):
            return status.isAllowed && !status.isBusy
        case let .systemPicker(status):
            return status.isAllowed && !status.isBusy
        case .none:
            assertionFailure("Unexpected item type")
            return false
        }
    }

    internal func _toggleExpanded(_ item: Item, section: Section) {
        var snapshot = _dataSource.snapshot(for: section)
        guard snapshot.contains(item) else { return }
        if snapshot.isExpanded(item) {
            snapshot.collapse([item])
            _expandedItems.remove(item)
        } else {
            snapshot.expand([item])
            _expandedItems.insert(item)
        }
        _dataSource.apply(snapshot, to: section)
    }
}

extension ConnectionTypePickerVC {
    internal func _applySnapshot(animated: Bool) {
        var snapshot = Snapshot()
        let remoteConnectionsSection = Section.remoteConnections(
            header: LString.directConnectionTitle,
            footer: LString.directConnectionDescription
        )

        var sectionSnapshot = SectionSnapshot()
        for service in RemoteConnectionType.Service.allCases {
            append(service: service, to: &sectionSnapshot)
        }
        if sectionSnapshot.items.count > 0 {
            snapshot.appendSections([remoteConnectionsSection])
        }

        var areAllSectionsEmpty = sectionSnapshot.items.isEmpty
        let areOtherLocationsAllowed = ManagedAppConfig.shared.areSystemFileProvidersAllowed
        if showsOtherLocations && areOtherLocationsAllowed {
            areAllSectionsEmpty = false
            let otherLocationsSection = Section.otherLocations(
                header: nil,
                footer: LString.integrationViaFilesAppDescription
            )
            snapshot.appendSections([otherLocationsSection])
            snapshot.appendItems(
                [.systemPicker(status: Item.Status(
                    isAllowed: areOtherLocationsAllowed,
                    isBusy: _isBusy,
                    needsPremium: false))
                ],
                toSection: otherLocationsSection
            )
        }

        if areAllSectionsEmpty {
            contentUnavailableConfiguration = makeContentUnavailableConfiguration()
            _dataSource.apply(snapshot, animatingDifferences: animated)
        } else {
            contentUnavailableConfiguration = nil
            _dataSource.apply(snapshot, animatingDifferences: animated)
            if sectionSnapshot.items.count > 0 {
                _dataSource.apply(sectionSnapshot, to: remoteConnectionsSection, animatingDifferences: animated)
            }
        }
    }

    private func append(service: RemoteConnectionType.Service, to sectionSnapshot: inout SectionSnapshot) {
        let serviceConnections = RemoteConnectionType.allValues
            .filter { service.contains(connectionType: $0) }
            .filter { _isConnectionAllowed($0) }

        guard serviceConnections.count > 0 else { return }

        if serviceConnections.count == 1,
           let theOnlyConnection = serviceConnections.first
        {
            let theOnlyConnectionItem = Item.remoteConnection(
                theOnlyConnection,
                status: Item.Status(
                    isAllowed: _isConnectionAllowed(theOnlyConnection),
                    isBusy: _isBusy,
                    needsPremium: theOnlyConnection.isPremiumUpgradeRequired
                )
            )
            sectionSnapshot.append([theOnlyConnectionItem])
            return
        }

        let serviceItem = Item.service(
            service: service,
            status: .init(
                isAllowed: serviceConnections.contains(where: { _isConnectionAllowed($0) }),
                isBusy: _isBusy,
                needsPremium: false
            )
        )
        sectionSnapshot.append([serviceItem])
        let connectionItems = serviceConnections.map { connectionType in
            Item.remoteConnection(connectionType, status: Item.Status(
                isAllowed: _isConnectionAllowed(connectionType),
                isBusy: _isBusy,
                needsPremium: connectionType.isPremiumUpgradeRequired
            ))
        }
        sectionSnapshot.append(connectionItems, to: serviceItem)

        let isExpanded = _expandedItems.contains(where: {
            if case let .service(serviceInfo, _) = $0 {
                return serviceInfo == service
            } else {
                return false
            }
        })
        if isExpanded {
            sectionSnapshot.expand([serviceItem])
        }
    }

    private func makeContentUnavailableConfiguration() -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.empty()
        config.text = LString.Error.storageAccessDeniedByOrg
        config.textProperties.color = .placeholderText
        config.image = .symbol(.managedParameter)
        config.imageProperties.maximumSize = CGSize(width: 0, height: 64)
        config.imageProperties.tintColor = .placeholderText
        return config
    }
}
