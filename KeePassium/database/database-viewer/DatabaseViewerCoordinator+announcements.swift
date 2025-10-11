//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    internal func _updateAnnouncements() {
        guard let _topGroupViewer else {
            assertionFailure()
            return
        }

        var announcements = [AnnouncementItem]()

        let status = _databaseFile.status
        if status.contains(.localFallback) {
            announcements.append(makeFallbackDatabaseAnnouncement(for: _topGroupViewer))
        } else if status.contains(.readOnly) {
            announcements.append(makeReadOnlyDatabaseAnnouncement(for: _topGroupViewer))
        }

        if _databaseFile.hasPendingOperations() {
            announcements.append(makePendingOperationsAnnouncement(
                for: _topGroupViewer,
                isProblematic: _databaseFile.someOperationsFailed,
                allowSaving: _canEditDatabase
            ))
        }

        if let whatsNewAnnouncement = WhatsNewHelper.makeAnnouncement(
            presenter: _topGroupViewer,
            completion: { [weak self] in self?.refresh(animated: true) }
        ) {
            announcements.append(whatsNewAnnouncement)
        }

        if let appLockSetupAnnouncement = maybeMakeAppLockSetupAnnouncement(for: _topGroupViewer) {
            announcements.append(appLockSetupAnnouncement)
        }

        if ProcessInfo.isRunningOnMac,
           _topGroupViewer.isEditing
        {
            announcements.append(.macMultiSelectHint())
        }

        if announcements.isEmpty,
           let donationAnnouncement = maybeMakeDonationAnnouncement(for: _topGroupViewer) {
            announcements.append(donationAnnouncement)
        }
        _announcementCount = announcements.count
        _topGroupViewer.setAnnouncements(announcements)
    }
}

extension DatabaseViewerCoordinator {
    private func shouldOfferAppLockSetup() -> Bool {
        let settings = Settings.current
        if settings.isHideAppLockSetupReminder {
            return false
        }
        let isDataVulnerable = settings.isRememberDatabaseKey && !settings.isAppLockEnabled
        return isDataVulnerable
    }

    private func maybeMakeAppLockSetupAnnouncement(
        for viewController: GroupViewerVC
    ) -> AnnouncementItem? {
        guard  shouldOfferAppLockSetup() else {
            return nil
        }
        let announcement = AnnouncementItem(
            title: LString.titleAppProtection,
            body: LString.appProtectionDescription,
            image: .symbol(.appProtection),
            action: UIAction(
                title: LString.callToActionActivateAppProtection,
                handler: { [weak self] _ in
                    self?._startAppProtectionSetup()
                }
            ),
            onDidPressClose: { [weak self] _ in
                Settings.current.isHideAppLockSetupReminder = true
                self?._updateAnnouncements()
            }
        )
        return announcement
    }

    private func makeFallbackDatabaseAnnouncement(
        for viewController: GroupViewerVC
    ) -> AnnouncementItem {
        let originalRef: URLReference = _databaseFile.originalReference
        let recoveryAction: UIAction?
        switch originalRef.error {
        case .authorizationRequired(_, let recoveryActionTitle):
            recoveryAction = UIAction(
                title: recoveryActionTitle,
                handler: { [weak self] _ in
                    guard let self else { return }
                    delegate?.didPressReinstateDatabase(originalRef, in: self)
                    _updateAnnouncements()
                }
            )
        default:
            recoveryAction = nil
        }
        return AnnouncementItem(
            title: LString.databaseIsFallbackCopy,
            body: originalRef.error?.errorDescription,
            image: .symbol(.iCloudSlash),
            action: recoveryAction
        )
    }

    private func makeReadOnlyDatabaseAnnouncement(
        for viewController: GroupViewerVC
    ) -> AnnouncementItem {
        return AnnouncementItem(
            title: nil,
            body: LString.databaseIsReadOnly,
        )
    }

    private func makePendingOperationsAnnouncement(
        for viewController: GroupViewerVC,
        isProblematic: Bool,
        allowSaving: Bool
    ) -> AnnouncementItem {
        var messages = [LString.titleDatabaseHasUnsavedChanges]
        if isProblematic {
            messages.append(LString.messageCouldNotApplySomeChanges)
        }

        let saveAction: UIAction?
        if allowSaving {
            saveAction = UIAction(
                title: isProblematic ? LString.actionForceSave : LString.actionSaveChanges,
                handler: { [weak self] _ in
                    guard let self else { return }
                    Diag.info("Will save pending changes on user request")
                    _showingProblematicOperationsAlert(isProblematic, presenter: viewController) {
                        [weak self] in
                        self?._maybeApplyAndSavePendingChanges(recoveryMode: isProblematic)
                    }
                }
            )
        } else {
            saveAction = nil
        }

        return AnnouncementItem(
            title: LString.titleUnsavedChanges,
            body: messages.joined(separator: "\n\n"),
            image: .symbol(.unsavedChanges, tint: .warningMessage),
            action: saveAction
        )
    }

    private func maybeMakeDonationAnnouncement(
        for viewController: GroupViewerVC
    ) -> AnnouncementItem? {
        let premiumStatus = PremiumManager.shared.status
        guard TipBox.shouldSuggestDonation(status: premiumStatus) else {
            return nil
        }

        let announcement = AnnouncementItem(
            title: nil,
            body: LString.tipBoxDescription2,
            image: .symbol(.heart)?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
            action: UIAction(
                title: LString.tipBoxCallToAction2,
                handler: { [weak self] _ in
                    self?._showTipBox()
                    self?._updateAnnouncements()
                }
            ),
            onDidPressClose: { [weak self] _ in
                TipBox.registerTipBoxSeen()
                self?._updateAnnouncements()
            }
        )
        return announcement
    }
}
