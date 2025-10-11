//  KeePassium Password Manager
//  Copyright © 2018-2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

public final class PendingDatabaseTransaction: Codable {
    public var count: Int { operations.count }
    private var operations: [DatabaseOperation]

    public private(set) var recoveryGroup: Group?

    init(operations: [DatabaseOperation] = []) {
        self.operations = operations
    }

    private enum CodingKeys: CodingKey {
        case operations
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            operations.map { DatabaseOperationWrapper(base: $0) },
            forKey: .operations
        )
    }

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operations = try container
            .decode([DatabaseOperationWrapper].self, forKey: .operations)
            .map { $0.base }
    }

    func apply(to databaseFile: DatabaseFile, startingFrom: Int, recoveryMode: Bool) throws -> Int {
        let opsToApply = operations.suffix(from: startingFrom)
        Diag.debug("Will apply pending database operations (from \(startingFrom), \(opsToApply.count) in total)")
        guard let rootGroup = databaseFile.database.root else {
            Diag.error("Database is empty, cancelling")
            return 0
        }

        let recoveryConfig: DatabaseOperation.RecoveryConfig?
        if recoveryMode {
            let recoveryGroup = rootGroup.createGroup(detached: false)
            recoveryGroup.name = String.localizedStringWithFormat(
                LString.recoveredEntriesGroupNameTemplate,
                Date.now.formatted(date: .abbreviated, time: .omitted))
            recoveryConfig = DatabaseOperation.RecoveryConfig(
                replacementParent: recoveryGroup,
                acceptIfExists: true,
                createIfMissing: true)
        } else {
            recoveryConfig = nil
        }

        do {
            try opsToApply.forEach { operation in
                try operation.apply(to: databaseFile, recovery: recoveryConfig)
            }
            maybeRemoveRecoveryGroup(recoveryConfig?.replacementParent)
        } catch {
            Diag.error("Operation failed, cancelling [message: \(error)]")
            maybeRemoveRecoveryGroup(recoveryConfig?.replacementParent)
            throw error
        }

        let appliedCount = opsToApply.count
        Diag.debug("\(appliedCount) operations applied successfully")
        return appliedCount
    }

    @discardableResult
    private func maybeRemoveRecoveryGroup(_ recoveryGroup: Group?) -> Bool {
        guard let recoveryGroup else {
            self.recoveryGroup = nil
            return false
        }
        if recoveryGroup.groups.isEmpty && recoveryGroup.entries.isEmpty {
            Diag.debug("Removing unused recovery group")
            recoveryGroup.parent?.remove(group: recoveryGroup)
            self.recoveryGroup = nil
            return true
        } else {
            Diag.debug("Preserving recovery group")
            self.recoveryGroup = recoveryGroup
            return false
        }
    }

    @discardableResult
    func add(_ operation: DatabaseOperation) -> Self {
        operations.append(operation)
        return self
    }

    @discardableResult
    func add(_ operations: [DatabaseOperation]) -> Self {
        self.operations.append(contentsOf: operations)
        return self
    }

    func dropFirst(_ count: Int) {
        operations = [DatabaseOperation](operations.dropFirst(count))
    }
}

private struct DatabaseOperationWrapper: Codable {
    var base: DatabaseOperation

    private enum CodingKeys: String, CodingKey {
        case kind
    }

    init(base: DatabaseOperation) {
        self.base = base
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base)
    }

    typealias StringDict = [String: Any]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)

        switch DatabaseOperation.Kind(rawValue: kind) {
        case .createEntry:
            self.base = try CreateEntryOperation(from: decoder)
        case .editEntry:
            self.base = try EditEntryOperation(from: decoder)
        case .addEntryURL:
            self.base = try AddEntryURLOperation(from: decoder)
        case .none:
            Diag.error("Unexpected operation kind: \(kind)")
            throw DecodingError.dataCorruptedError(
                forKey: .kind,
                in: container,
                debugDescription: "Unexpected operation kind")
        }
    }
}
