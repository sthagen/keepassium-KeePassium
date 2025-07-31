//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabasePickerCoordinator {
    internal func _updateAnnouncements() {
        var announcements: [AnnouncementItem] = []

        if mode == .autoFill,
           FileKeeper.shared.areSandboxFilesLikelyMissing()
        {
            announcements.append(makeSandboxUnreachableAnnouncement())
        }

        if _hasPendingTransactions {
            announcements.append(makePendingTransactionsAnnouncement())
        }
        self.announcements = announcements
    }

    private func makeSandboxUnreachableAnnouncement() -> AnnouncementItem {
        return AnnouncementItem(
            title: nil,
            body: LString.messageLocalFilesMissing,
            actionTitle: LString.callToActionOpenTheMainApp,
            image: .symbol(.questionmarkFolder),
            onDidPressAction: { announcementView in
                URLOpener(announcementView).open(url: AppGroup.launchMainAppURL)
            }
        )
    }

    private func makePendingTransactionsAnnouncement() -> AnnouncementItem {
        if AppGroup.isAppExtension {
            return AnnouncementItem(
                title: LString.titleUnsavedChanges,
                body: LString.titleOpenAppToSaveChanges,
                actionTitle: LString.callToActionOpenTheMainApp,
                image: .symbol(.unsavedChanges, tint: .warningMessage),
                onDidPressAction: { [weak presenter = _presenterForModals] _ in
                    URLOpener(presenter).open(url: AppGroup.launchMainAppURL)
                }
            )
        } else {
            return AnnouncementItem(
                title: LString.titleUnsavedChanges,
                body: LString.titleSomeDatabasesHaveUnsavedChanges,
                image: .symbol(.unsavedChanges, tint: .warningMessage)
            )
        }
    }
}
