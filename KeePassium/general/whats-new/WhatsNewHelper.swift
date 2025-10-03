//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib
import UIKit
import WhatsNewKit

final class WhatsNewHelper {
    private static let version: WhatsNew.Version = .current()
    private static let versionStore = UserDefaultsWhatsNewVersionStore(userDefaults: .appGroupShared)

    static func makeAnnouncement(
        presenter: UIViewController,
        completion: @escaping () -> Void
    ) -> AnnouncementItem? {
        if versionStore.hasPresented(version) {
            return nil
        }

        return AnnouncementItem(
            title: "\(AppInfo.name) \(version.formatted)",
            body: LString.WhatsNew.announcementMessage,
            image: UIImage.symbol(.wandAndStars),
            action: UIAction(
                title: LString.WhatsNew.titleWhatsNew,
                handler: { [weak presenter] _ in
                    guard let presenter else { return }
                    showFullPage(presenter: presenter)
                    versionStore.save(presentedVersion: version)
                    completion()
                }
            ),
            onDidPressClose: { _ in
                versionStore.save(presentedVersion: version)
                completion()
            }
        )
    }

    private static func showFullPage(presenter: UIViewController) {
        let whatsNewController = WhatsNewViewController(
            whatsNew: getWhatsNew(),
            layout: .init(
                footerPrimaryActionButtonCornerRadius: 10,
            )
        )
        whatsNewController.modalPresentationStyle = .formSheet
        presenter.present(whatsNewController, animated: true)
    }

    private static func getWhatsNew() -> WhatsNew {
        var features = [WhatsNew.Feature]()
        if !BusinessModel.isIntuneEdition {
            features.append(.init(
                image: .init(systemName: SymbolName.personBadgePlus.rawValue),
                title: .init(NSLocalizedString(
                    "[WhatsNew/Feature/CreativeAutoFill/title]",
                    value: "Faster Sign-Ups",
                    comment: "Title of a feature highlight, a noun phrase."
                )),
                subtitle: .init(NSLocalizedString(
                    "[WhatsNew/Feature/CreativeAutoFill/description]",
                    value: "Create new entries in AutoFill with main fields pre-filled automatically.",
                    comment: "Description of a feature highlight, a call to action."
                ))
            ))
            features.append(.init(
                image: .init(systemName: SymbolName.personCropCircleBadgeCheckmark.rawValue),
                title: .init(NSLocalizedString(
                    "[WhatsNew/Feature/AutoFillWithMemory/title]",
                    value: "Smarter AutoFill",
                    comment: "Title of a feature highlight, a noun phrase."
                )),
                subtitle: .init(NSLocalizedString(
                    "[WhatsNew/Feature/AutoFillWithMemory/description]",
                    value: "KeePassium remembers the entry you choose on each website.",
                    comment: "Description of a feature highlight, a call to action."
                ))
            ))
        }
        if ProcessInfo.isRunningOnMac {
            features.append(.init(
                image: .init(systemName: SymbolName.keyboard.rawValue),
                title: .init(NSLocalizedString(
                    "[WhatsNew/Feature/AutoType/title]",
                    value: "Password Auto-Type",
                    comment: "Title of a feature highlight, a noun phrase."
                )),
                subtitle: .init(NSLocalizedString(
                    "[WhatsNew/Feature/AutoType/description]",
                    value: "Quickly sign in to any app or web service using key-press emulation.",
                    comment: "Description of a feature highlight, a call to action."
                ))
            ))
        }
        features.append(.init(
            image: .init(name: SymbolName.networkBadgeShield.rawValue),
            title: .init(NSLocalizedString(
                "[WhatsNew/Feature/AppScopedConnections/title]",
                value: "Safer Cloud Access",
                comment: "Title of a feature highlight, a noun phrase."
            )),
            subtitle: .init(NSLocalizedString(
                "[WhatsNew/Feature/AppScopedConnections/description]",
                value: "Protect your cloud data using app-folder-only permissions.",
                comment: "Description of a feature highlight, a call to action."
            ))
        ))
        features.append(.init(
            image: .init(systemName: SymbolName.handPointUpLeftAndText.rawValue),
            title: .init(NSLocalizedString(
                "[WhatsNew/Feature/MoreInteractions/title]",
                value: "More Ways to Interact",
                comment: "Title of a feature highlight, a noun phrase."
            )),
            subtitle: .init(NSLocalizedString(
                "[WhatsNew/Feature/MoreInteractions/description]",
                value: "Drag and drop, select multiple items, and browse alphabetically.",
                comment: "Description of a feature highlight, a call to action. `Browse alphabetically` refers to a phonebook-like index with letters."
                // swiftlint:disable:previous line_length
            ))
        ))

        return WhatsNew(
            version: "2.4.166",
            title: WhatsNew.Title(text: .init(LString.WhatsNew.fullTitle)),
            features: features,
            primaryAction: WhatsNew.PrimaryAction(
                title: .init(LString.actionContinue),
                hapticFeedback: .notification(.success)
            ),
            secondaryAction: WhatsNew.SecondaryAction(
                title: .init(LString.WhatsNew.titleFullChangelog),
                action: .openURL(URL.AppHelp.changeLog)
            )
        )
    }
}

extension WhatsNew.Version {
    var formatted: String {
        "\(major).\(minor)"
    }
}

extension LString {
    enum WhatsNew {
        static let fullTitle = NSLocalizedString(
            "[WhatsNew/fullTitle]",
            bundle: Bundle.main,
            value: "What's New in KeePassium",
            comment: "Full title for release highlights"
        )
        static let announcementMessage = NSLocalizedString(
            "[WhatsNew/Announcement/body]",
            bundle: Bundle.main,
            value: "Discover new features and improvements in KeePassium.",
            comment: "Call to action in What's New announcement"
        )
        static let titleWhatsNew = NSLocalizedString(
            "[WhatsNew/Announcement/button]",
            bundle: Bundle.main,
            value: "What's New",
            comment: "Button which opens the What's New screen."
        )
        static let titleFullChangelog = NSLocalizedString(
            "[WhatsNew/FullChangelog/title]",
            bundle: Bundle.main,
            value: "Detailed Changelog",
            comment: "Title of the detailed history of app changes over time."
        )
    }
}
