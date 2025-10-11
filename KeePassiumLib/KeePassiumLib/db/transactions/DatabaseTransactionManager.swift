//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

final public class DatabaseTransactionManager {
    public static func hasPendingTransaction(for databaseRef: URLReference) -> Bool {
        guard let descriptor = databaseRef.getDescriptor() else {
            Diag.error("Database file descriptor is undefined, assuming nothing pending")
            assertionFailure()
            return false
        }
        return hasPendingTransaction(for: descriptor)
    }

    public static func hasPendingTransaction(for descriptor: URLReference.Descriptor) -> Bool {
        do {
            return try Keychain.shared.hasPendingTransaction(for: descriptor)
        } catch {
            let message = (error as NSError).debugDescription
            Diag.error("Failed to check for pending transaction, assuming nothing pending [message: \(message)]")
            assertionFailure()
            return false
        }
    }

    internal static func getPendingTransaction(
        for databaseRef: URLReference
    ) throws -> PendingDatabaseTransaction? {
        guard let descriptor = databaseRef.getDescriptor() else {
            Diag.error("Database file descriptor is undefined, assuming nothing pending")
            assertionFailure()
            return nil
        }
        return try Keychain.shared.getPendingTransaction(for: descriptor)
    }

    internal static func updatePendingTransaction(
        for descriptor: URLReference.Descriptor,
        updater: (PendingDatabaseTransaction?) -> PendingDatabaseTransaction?
    ) throws {
        let transaction = try Keychain.shared.getPendingTransaction(for: descriptor)
        if let updatedTransaction = updater(transaction) {
            try Keychain.shared.storePendingTransaction(updatedTransaction, for: descriptor)
        } else {
            try Keychain.shared.erasePendingTransaction(for: descriptor)
        }
    }
}
