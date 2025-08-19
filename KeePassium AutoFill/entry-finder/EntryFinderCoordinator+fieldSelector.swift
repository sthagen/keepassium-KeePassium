//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

@available(iOS 18.0, *)
extension EntryFinderCoordinator {
    private static let nonSelectableFieldNames = Set([
        EntryField.title,
        EntryField.otpConfig1,
        EntryField.otpConfig2Seed,
        EntryField.otpConfig2Settings,
        EntryField.timeOtpLength,
        EntryField.timeOtpPeriod,
        EntryField.timeOtpSecret,
        EntryField.timeOtpAlgorithm,
        EntryField.tags
    ])

    internal func _getSelectableFields(for entry: Entry) -> [EntryField]? {
        var allFields = entry.fields
        if let totpGenerator = entry.totpGenerator() {
            let otpField = EntryField(name: LString.fieldOTP, value: totpGenerator.generate(), isProtected: false)
            allFields.append(otpField)
        }
        let category = ItemCategory.get(for: entry)
        let selectableFields = allFields
            .filter { !Self.nonSelectableFieldNames.contains($0.name) }
            .filter { $0.resolvedValue.isNotEmpty }
            .sorted(by: { category.compare($0.name, $1.name) })
        return selectableFields
    }

    internal func _getUpdatedFieldValue(_ field: EntryField, of entry: Entry) -> String {
        switch field.name {
        case LString.fieldOTP:
            guard let totpGenerator = entry.totpGenerator() else {
                Diag.warning("Failed to refresh OTP field value")
                assertionFailure("Should not really happen")
                return field.resolvedValue
            }
            return totpGenerator.generate()
        default:
            return field.resolvedValue
        }
    }
}
