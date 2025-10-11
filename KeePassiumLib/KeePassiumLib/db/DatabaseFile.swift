//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

public class DatabaseFile: Eraseable {

    public enum StatusFlag {
        case readOnly
        case localFallback
        case useStreams
    }
    public typealias Status = Set<StatusFlag>

    public let database: Database

    public private(set) var data: ByteArray

    public private(set) var storedDataSHA512: ByteArray

    public var fileURL: URL

    public private(set) var originalReference: URLReference!

    public var fileReference: URLReference?

    public private(set) var status: Status

    public var visibleFileName: String {
        return fileURL.lastPathComponent
    }

    public var descriptor: URLReference.Descriptor? {
        return fileReference?.getDescriptor()
    }

    private var _fileProvider: FileProvider?
    public var fileProvider: FileProvider? {
        get {
            return fileReference?.fileProvider ?? _fileProvider
        }
        set {
            _fileProvider = newValue
        }
    }

    private var pendingOperationsApplied = 0

    public private(set) var someOperationsFailed = false

    public private(set) var latestRecoveryGroup: Group?

    init(
        database: Database,
        data: ByteArray = ByteArray(),
        fileURL: URL,
        fileProvider: FileProvider?,
        status: Status
    ) {
        self.database = database
        self.data = data
        self.storedDataSHA512 = data.sha512
        self.fileURL = fileURL
        self._fileProvider = fileProvider
        self.fileReference = nil
        self.originalReference = nil
        self.status = status
    }

    init(
        database: Database,
        data: ByteArray = ByteArray(),
        fileURL: URL,
        fileReference: URLReference,
        originalReference: URLReference,
        status: Status
    ) {
        self.database = database
        self.data = data
        self.storedDataSHA512 = data.sha512
        self.fileURL = fileURL
        self.fileReference = fileReference
        self._fileProvider = nil
        self.originalReference = originalReference
        self.status = status
    }

    public func erase() {
        data.erase()
        database.erase()
        status.removeAll()
        pendingOperationsApplied = 0
        someOperationsFailed = false
    }

    public func resolveFileURL(
        timeout: Timeout,
        completionQueue: OperationQueue = .main,
        completion: @escaping (() -> Void)
    ) {
        guard let fileReference else {
            completion()
            return
        }
        fileReference.resolveAsync(timeout: timeout, callbackQueue: completionQueue) { result in
            switch result {
            case .success(let resolvedURL):
                self.fileURL = resolvedURL
            case .failure(let fileAccessError):
                Diag.error("Failed to resolve file reference [message: \(fileAccessError.localizedDescription)]")
            }
            completion()
        }
    }

    public func setData(_ data: ByteArray, updateHash: Bool) {
        self.data = data.clone()
        if updateHash {
            storedDataSHA512 = data.sha512
        }
    }
}

extension DatabaseFile {
    public func hasPendingOperations() -> Bool {
        return DatabaseTransactionManager.hasPendingTransaction(for: originalReference)
    }

    public func addPendingOperations(
        _ operations: [DatabaseOperation],
        apply: Bool
    ) throws {
        Diag.debug("Will store pending operations")
        guard let descriptor = originalReference?.getDescriptor() else {
            Diag.error("Database file descriptor is undefined, skipping")
            assertionFailure()
            return
        }
        try DatabaseTransactionManager.updatePendingTransaction(for: descriptor) { existingTransaction in
            let transaction = existingTransaction ?? PendingDatabaseTransaction()
            transaction.add(operations)
            return transaction
        }
        if apply {
            try applyUnappliedPendingOperations(recoveryMode: false)
        }
    }

    public func applyUnappliedPendingOperations(recoveryMode: Bool) throws {
        guard let transaction = try DatabaseTransactionManager.getPendingTransaction(for: originalReference) else {
            Diag.debug("No pending operations")
            return
        }

        let unappliedOpCount = transaction.count - pendingOperationsApplied
        guard unappliedOpCount > 0 else {
            Diag.debug("Found pending operations, all already applied")
            return
        }

        Diag.debug("Will apply \(unappliedOpCount) pending operations [recoveryMode: \(recoveryMode)]")
        do {
            pendingOperationsApplied += try transaction.apply(
                to: self,
                startingFrom: pendingOperationsApplied,
                recoveryMode: recoveryMode
            )
            latestRecoveryGroup = transaction.recoveryGroup
            someOperationsFailed = false
            Diag.debug("Pending operations applied successfully")
        } catch {
            someOperationsFailed = true
            latestRecoveryGroup = transaction.recoveryGroup
            StoreReviewSuggester.registerEvent(.trouble)
            throw error
        }
    }

    public func removeAppliedPendingOperations() throws {
        guard let descriptor = originalReference?.getDescriptor() else {
            Diag.warning("Database file descriptor is undefined. New database?")
            return
        }

        try DatabaseTransactionManager.updatePendingTransaction(for: descriptor) { transaction in
            guard let transaction else { return nil }
            Diag.debug("\(pendingOperationsApplied) of \(transaction.count) pending operations have been applied.")
            if transaction.count == pendingOperationsApplied {
                return nil
            } else if transaction.count > pendingOperationsApplied {
                transaction.dropFirst(pendingOperationsApplied)
                return transaction
            } else {
                assertionFailure()
                return transaction
            }
        }
        pendingOperationsApplied = 0
        someOperationsFailed = false
    }
}
