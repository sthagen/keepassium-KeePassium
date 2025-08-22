//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryFinderCoordinator {
    internal func _updateAnnouncements() {
        var announcements = [AnnouncementItem]()
        switch _entrySelectionMode {
        case .forPasskeyCreation:
            if _canCreatePasskeys {
                announcements.append(makePasskeyForExistingEntryAnnouncement(for: _entryFinderVC))
            }
        case .default:
            break
        }

        if _databaseFile.status.contains(.localFallback) {
            announcements.append(makeFallbackDatabaseAnnouncement(for: _entryFinderVC))
        }
        if _databaseFile.status.contains(.readOnly) {
            announcements.append(makeReadOnlyDatabaseAnnouncement(for: _entryFinderVC))
        }
        if _databaseFile.hasPendingOperations() {
            announcements.append(makePendingChangesAnnouncement(for: _entryFinderVC))
        }

        if announcements.isEmpty,
           let qafAnnouncment = maybeMakeQuickAutoFillAnnouncment(for: _entryFinderVC)
        {
            announcements.append(qafAnnouncment)
        }
        _entryFinderVC.setAnnouncements(announcements)
    }

    private func maybeMakeQuickAutoFillAnnouncment(for viewController: EntryFinderVC) -> AnnouncementItem? {
        let isQuickTypeEnabled = DatabaseSettingsManager.shared.isQuickTypeEnabled(_databaseFile)
        guard !isQuickTypeEnabled && QuickAutoFillPrompt.shouldShow else {
            return nil
        }

        let announcement = AnnouncementItem(
            title: LString.callToActionActivateQuickAutoFill,
            body: LString.premiumFeatureQuickAutoFillDescription,
            image: .symbol(.infoCircle),
            action: UIAction(
                title: LString.actionLearnMore,
                handler: {[weak viewController] _ in
                    QuickAutoFillPrompt.dismissDate = Date.now
                    URLOpener(viewController).open(url: URL.AppHelp.quickAutoFillIntro)
                }
            ),
            onDidPressClose: { [weak self] _ in
                guard let self else { return }
                QuickAutoFillPrompt.dismissDate = Date.now
                refresh()
            }
        )
        QuickAutoFillPrompt.lastSeenDate = Date.now
        return announcement
    }

    private func makeFallbackDatabaseAnnouncement(for viewController: EntryFinderVC) -> AnnouncementItem {
        let originalRef: URLReference = _databaseFile.originalReference
        let action: UIAction?
        switch originalRef.error {
        case .authorizationRequired(_, let recoveryAction):
            action = UIAction(
                title: recoveryAction,
                handler: { [weak self] _ in
                    guard let self else { return }
                    delegate?.didPressReinstateDatabase(originalRef, in: self)
                    refresh()
                }
            )
        default:
            action = nil
        }
        let announcement = AnnouncementItem(
            title: LString.databaseIsFallbackCopy,
            body: originalRef.error?.errorDescription,
            image: .symbol(.iCloudSlash),
            action: action,
        )
        return announcement
    }

    private func makeReadOnlyDatabaseAnnouncement(for viewController: EntryFinderVC) -> AnnouncementItem {
        return AnnouncementItem(
            title: nil,
            body: LString.databaseIsReadOnly,
            image: nil
        )
    }

    private func makePendingChangesAnnouncement(for viewController: EntryFinderVC) -> AnnouncementItem {
        return AnnouncementItem(
            title: LString.titleUnsavedChanges,
            body: LString.titleOpenAppToSaveChanges,
            image: .symbol(.unsavedChanges, tint: .warningMessage),
            action: UIAction(
                title: LString.callToActionOpenTheMainApp,
                handler: { [weak viewController] _ in
                    URLOpener(viewController).open(url: AppGroup.launchMainAppURL)
                }
            )
        )
    }

    private func makePasskeyForExistingEntryAnnouncement(
        for viewController: EntryFinderVC
    ) -> AnnouncementItem {
        return AnnouncementItem(
            title: nil,
            body: LString.callToActionSelectEntryForPasskey,
            image: .symbol(.infoCircle)
        )
    }
}
