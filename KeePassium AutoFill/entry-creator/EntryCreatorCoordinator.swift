//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

protocol EntryCreatorCoordinatorDelegate: AnyObject {
    func didCreateEntry(_ entry: Entry, in coordinator: EntryCreatorCoordinator)
}

final class EntryCreatorCoordinator: BaseCoordinator {
    weak var delegate: EntryCreatorCoordinatorDelegate?

    let _databaseFile: DatabaseFile
    let _entryCreatorVC: EntryCreatorVC
    let _searchContext: AutoFillSearchContext
    var _entryData: EntryCreatorEntryData!

    init(
        router: NavigationRouter,
        databaseFile: DatabaseFile,
        searchContext: AutoFillSearchContext
    ) {
        self._databaseFile = databaseFile
        self._searchContext = searchContext
        let itemDecorator = ItemDecorator()
        let toolbarDecorator = ToolbarDecorator()
        self._entryCreatorVC = EntryCreatorVC(
            itemDecorator: itemDecorator,
            toolbarDecorator: toolbarDecorator
        )
        super.init(router: router)

        _entryCreatorVC.delegate = self
        itemDecorator.coordinator = self
        toolbarDecorator.coordinator = self
    }

    override func start() {
        super.start()
        _makeInitialEntryData()
        _pushInitialViewController(_entryCreatorVC, to: _router, animated: true)
        refresh()
    }

    override func refresh() {
        super.refresh()
        _updateAnnouncements()
        _entryCreatorVC.setEntryData(_entryData)
        _entryCreatorVC.setLocation(_entryData.parentGroup)
        _entryCreatorVC.refresh(animated: true)
    }
}

extension EntryCreatorCoordinator {
    var _isEntryDataEnough: Bool {
        let sanitizedTitle = _entryData.title.trimmingCharacters(in: .whitespaces)
        return sanitizedTitle.isNotEmpty
    }

    func _didSelectLocation(_ group: Group) {
        _entryData.parentGroup = group
        refresh()
        _entryCreatorVC.accessibilityFocusLocation()
    }

    func _didSelectUsername(_ username: String) {
        _entryData.username = username
        refresh()
        _entryCreatorVC.setFirstResponderField(EntryField.userName)
    }

    func _didSetPassword(_ password: String) {
        _entryData.password = password
        refresh()
        _entryCreatorVC.setFirstResponderField(EntryField.password)
    }

    func _updateAnnouncements() {
        var announcements = [AnnouncementItem]()
        if let premiumAnnouncement = maybeMakePremiumUpgradeAnnouncement(for: _entryCreatorVC) {
            announcements.append(premiumAnnouncement)
        }
        _entryCreatorVC.setAnnouncements(announcements)
    }

    private func maybeMakePremiumUpgradeAnnouncement(
        for viewController: UIViewController
    ) -> AnnouncementItem? {
        if PremiumManager.shared.isAvailable(feature: .canCreateEntriesInAutoFill) {
            return nil
        }
        return AnnouncementItem(
            title: PremiumFeature.canCreateEntriesInAutoFill.titleName,
            body: PremiumFeature.canCreateEntriesInAutoFill.upgradeNoticeText,
            image: .symbol(.premiumBenefitCreativeAutoFill),
            action: UIAction(
                title: LString.actionUpgradeToPremium,
                handler: { [weak self, weak _entryCreatorVC] _ in
                    guard let self, let _entryCreatorVC else { return }
                    showPremiumUpgrade(in: _entryCreatorVC)
                }
            ),
            onDidPressClose: nil
        )
    }

    func _finishCreation() {
        assert(_isEntryDataEnough)
        let newEntryUUID = UUID()
        let operations = DatabaseOperation.createEntry(
            uuid: newEntryUUID,
            title: _entryData.title,
            username: _entryData.username,
            password: _entryData.password,
            url: _entryData.url,
            notes: _entryData.notes,
            in: _entryData.parentGroup
        )
        do {
            try _databaseFile.addPendingOperations(operations, apply: true)
            guard let newEntry = _databaseFile.database.root?.findEntry(byUUID: newEntryUUID) else {
                Diag.error("Could not find newly created entry")
                assertionFailure()
                _presenterForModals.showErrorAlert("Could not find newly created entry.")
                return
            }
            delegate?.didCreateEntry(newEntry, in: self)
        } catch {
            _presenterForModals.showErrorAlert(error)
        }
    }
}

extension EntryCreatorCoordinator: EntryCreatorVC.Delegate {
    func didChangeValue(of fieldName: String, to newValue: String, in viewController: EntryCreatorVC) {
        switch fieldName {
        case EntryField.title:
            _entryData.title = newValue
        case EntryField.userName:
            _entryData.username = newValue
        case EntryField.password:
            _entryData.password = newValue
        case EntryField.url:
            _entryData.url = newValue
        case EntryField.notes:
            _entryData.notes = newValue
        default:
            assertionFailure("Unexpected field name")
        }
        viewController.updateToolbars(animated: true)
    }

    func didChangeVisibility(of fieldName: String, isHidden: Bool, in viewController: EntryCreatorVC) {
        switch fieldName {
        case EntryField.password:
            _entryData.isPasswordProtected = isHidden
            DispatchQueue.main.async {
                self.refresh()
            }
        default:
            break
        }
    }

    func didPressDone(in viewController: EntryCreatorVC) {
        performPremiumActionOrOfferUpgrade(for: .canCreateEntriesInAutoFill, in: viewController) {
            [weak self] in
            self?._finishCreation()
        }
    }
}
