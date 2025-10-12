//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabasePickerCoordinator {
    internal func _makeAnnouncements() -> [AnnouncementItem] {
        var announcements = [AnnouncementItem]()

        switch mode {
        case .full:
            if _hasIncomingOTPAuthURL {
                announcements.append(makeIncomingOTPAuthURLAnnouncement(for: _filePickerVC))
            }
        case .autoFill:
            if FileKeeper.shared.areSandboxFilesLikelyMissing() {
                announcements.append(makeSandboxUnreachableAnnouncement(for: _filePickerVC))
            }
        case .light:
            break
        }

        if _hasPendingTransactions {
            announcements.append(makePendingTransactionsAnnouncement(for: _filePickerVC))
        }

        #if MAIN_APP
        if let whatsNewAnnouncement = WhatsNewHelper.makeAnnouncement(
            presenter: _filePickerVC,
            completion: { [weak self] in self?.refresh(animated: true, reloadInfo: false) }
        ) {
            announcements.append(whatsNewAnnouncement)
        }
        #endif

        if ProcessInfo.isRunningOnMac,
           _filePickerVC.isEditing
        {
            announcements.append(.macMultiSelectHint())
        }
        return announcements
    }

    private func makeSandboxUnreachableAnnouncement(for viewController: UIViewController) -> AnnouncementItem {
        return AnnouncementItem(
            title: nil,
            body: LString.messageLocalFilesMissing,
            image: .symbol(.questionmarkFolder),
            action: UIAction(
                title: LString.callToActionOpenTheMainApp,
                handler: { [weak viewController] _ in
                    URLOpener(viewController).open(url: AppGroup.launchMainAppURL)
                }
            )
        )
    }

    private func makePendingTransactionsAnnouncement(for viewController: UIViewController) -> AnnouncementItem {
        if AppGroup.isAppExtension {
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
        } else {
            return AnnouncementItem(
                title: LString.titleUnsavedChanges,
                body: LString.titleSomeDatabasesHaveUnsavedChanges,
                image: .symbol(.unsavedChanges, tint: .warningMessage)
            )
        }
    }

    private func makeIncomingOTPAuthURLAnnouncement(for viewController: UIViewController) -> AnnouncementItem {
        return AnnouncementItem(
            title: LString.titleSetupVerificationOTPCode,
            body: LString.messageSelectDatabaseForOTPSetup,
            image: .symbol(.oneTimePassword),
            onDidPressClose: { [weak self] _ in
                guard let self else { return }
                delegate?.didCancelOTPAuthURLImport(in: self)
            }
        )
    }
}
