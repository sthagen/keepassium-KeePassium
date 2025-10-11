//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation

extension Settings {

    public enum FilesSortOrder: Int {
        public static let allValues = [
            noSorting,
            nameAsc, nameDesc,
            creationTimeDesc, creationTimeAsc,
            modificationTimeDesc, modificationTimeAsc]

        case noSorting
        case nameAsc
        case nameDesc
        case creationTimeAsc
        case creationTimeDesc
        case modificationTimeAsc
        case modificationTimeDesc

        public var isAscending: Bool? {
            switch self {
            case .noSorting:
                return nil
            case .nameAsc, .creationTimeAsc, .modificationTimeAsc:
                return true
            case .nameDesc, .creationTimeDesc, .modificationTimeDesc:
                return false
            }
        }

        public var title: String {
            switch self {
            case .noSorting:
                return LString.titleSortByNone
            case .nameAsc, .nameDesc:
                return LString.titleSortByFileName
            case .creationTimeAsc, .creationTimeDesc:
                return LString.itemCreationDate
            case .modificationTimeAsc, .modificationTimeDesc:
                return LString.itemLastModificationDate
            }
        }

        public func compare(_ lhs: URLReference, _ rhs: URLReference) -> Bool {
            switch self {
            case .noSorting:
                return false
            case .nameAsc:
                return compareFileNames(lhs, rhs, criteria: .orderedAscending)
            case .nameDesc:
                return compareFileNames(lhs, rhs, criteria: .orderedDescending)
            case .creationTimeAsc:
                return compareCreationTimes(lhs, rhs, criteria: .orderedAscending)
            case .creationTimeDesc:
                return compareCreationTimes(lhs, rhs, criteria: .orderedDescending)
            case .modificationTimeAsc:
                return compareModificationTimes(lhs, rhs, criteria: .orderedAscending)
            case .modificationTimeDesc:
                return compareModificationTimes(lhs, rhs, criteria: .orderedDescending)
            }
        }

        private func compareFileNames(_ lhs: URLReference, _ rhs: URLReference, criteria: ComparisonResult) -> Bool {
            let lhsInfo = lhs.getCachedInfoSync(canFetch: false)
            guard let lhsName = lhsInfo?.fileName ?? lhs.url?.lastPathComponent else {
                return false
            }
            let rhsInfo = rhs.getCachedInfoSync(canFetch: false)
            guard let rhsName = rhsInfo?.fileName ?? rhs.url?.lastPathComponent else {
                return true
            }
            return lhsName.localizedCaseInsensitiveCompare(rhsName) == criteria
        }

        private func compareCreationTimes(
            _ lhs: URLReference,
            _ rhs: URLReference,
            criteria: ComparisonResult
        ) -> Bool {
            guard let lhsInfo = lhs.getCachedInfoSync(canFetch: false) else { return false }
            guard let rhsInfo = rhs.getCachedInfoSync(canFetch: false) else { return true }
            guard let lhsDate = lhsInfo.creationDate else { return true }
            guard let rhsDate = rhsInfo.creationDate else { return false }
            return lhsDate.compare(rhsDate) == criteria
        }

        private func compareModificationTimes(
            _ lhs: URLReference,
            _ rhs: URLReference,
            criteria: ComparisonResult
        ) -> Bool {
            guard let lhsInfo = lhs.getCachedInfoSync(canFetch: false) else { return false }
            guard let rhsInfo = rhs.getCachedInfoSync(canFetch: false) else { return true }
            guard let lhsDate = lhsInfo.modificationDate else { return true }
            guard let rhsDate = rhsInfo.modificationDate else { return false }
            return lhsDate.compare(rhsDate) == criteria
        }
    }

    public var filesSortOrder: FilesSortOrder {
        get {
            if let rawValue = UserDefaults.appGroupShared
                    .object(forKey: Keys.filesSortOrder.rawValue) as? Int,
               let sortOrder = FilesSortOrder(rawValue: rawValue)
            {
                return sortOrder
            }
            return FilesSortOrder.noSorting
        }
        set {
            let oldValue = filesSortOrder
            UserDefaults.appGroupShared.set(newValue.rawValue, forKey: Keys.filesSortOrder.rawValue)
            if newValue != oldValue {
                _postChangeNotification(changedKey: Keys.filesSortOrder)
            }
        }
    }

    public var isBackupFilesVisible: Bool {
        get {
            if let managedValue = ManagedAppConfig.shared.getBoolIfLicensed(.showBackupFiles) {
                return managedValue
            }
            let stored = UserDefaults.appGroupShared
                .object(forKey: Keys.backupFilesVisible.rawValue)
                as? Bool
            return stored ?? false
        }
        set {
            _updateAndNotify(
                oldValue: isBackupFilesVisible,
                newValue: newValue,
                key: .backupFilesVisible)
        }
    }
}
