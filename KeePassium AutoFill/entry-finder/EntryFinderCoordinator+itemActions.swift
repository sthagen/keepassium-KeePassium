//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryFinderCoordinator {
    final class ItemDecorator: EntryFinderItemDecorator {
        weak var coordinator: EntryFinderCoordinator?

        func getLeadingSwipeActions(for entry: Entry) -> [UIContextualAction]? {
            return nil
        }

        func getTrailingSwipeActions(for entry: Entry) -> [UIContextualAction]? {
            return nil
        }

        func getAccessories(for entry: Entry) -> [UICellAccessory]? {
            var result = [UICellAccessory]()
            if Passkey.probablyPresent(in: entry) {
                result.append(.passkeyPresenceIndicator())
            }
            if entry.hasValidTOTP {
                result.append(.otpPresenceIndicator())
            }
            switch coordinator?._autoFillMode {
            case .text:
                result.append(.outlineDisclosure())
            case .credentials, .oneTimeCode, .passkeyRegistration, .passkeyAssertion, .none:
                break
            }
            return result
        }

        func getContextMenu(for entry: Entry, at popoverAnchor: PopoverAnchor) -> UIMenu? {
            makeCopyEntryFieldMenu(for: entry, at: popoverAnchor)
        }
    }
}

extension EntryFinderCoordinator.ItemDecorator {
    static let fieldExcludedFromCopying = [
        EntryField.title,
        EntryField.otpConfig1,
        EntryField.otpConfig2Seed,
        EntryField.otpConfig2Settings,
        EntryField.timeOtpLength,
        EntryField.timeOtpPeriod,
        EntryField.timeOtpPeriod,
        EntryField.timeOtpSecret,
        EntryField.timeOtpAlgorithm,
        EntryField.passkeyCredentialID,
        EntryField.passkeyRelyingParty,
        EntryField.passkeyPrivateKeyPEM,
        EntryField.passkeyUserHandle,
        EntryField.passkeyUsername
    ]

    func makeCopyEntryFieldMenu(for entry: Entry, at popoverAnchor: PopoverAnchor) -> UIMenu? {
        let fields = entry.fields.filter {
            !$0.value.isEmpty && !Self.fieldExcludedFromCopying.contains($0.name)
        }
        guard !fields.isEmpty else { return nil }

        var fieldCopyActions = fields.map { field in
            let title = String.localizedStringWithFormat(
                LString.actionCopyToClipboardTemplate,
                field.visibleName
            )
            return UIAction(title: title) { [weak coordinator, weak field] _ in
                guard let field else { return }
                coordinator?._copyToClipboard(field.resolvedValue)
            }
        }

        if entry.hasValidTOTP {
            let title = String.localizedStringWithFormat(
                LString.actionCopyToClipboardTemplate,
                LString.fieldTOTP
            )
            let copyOTPAction = UIAction(title: title) { [weak coordinator, weak entry] _ in
                guard let totpValue = entry?.totpGenerator()?.generate() else {
                    assertionFailure()
                    return
                }
                coordinator?._copyToClipboard(totpValue)
            }
            fieldCopyActions.insert(copyOTPAction, at: 0)
        }

        return UIMenu(children: fieldCopyActions)
    }
}

extension EntryFinderCoordinator {
    internal func _copyToClipboard(_ text: String) {
        Clipboard.general.copyWithTimeout(text)
        _manualCopyTimestamp = .now
    }
}
