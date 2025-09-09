//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    internal enum ExternalUpdateResult {
        case hasChanged(ExternalUpdateBehavior)
        case isTheSame
    }

    internal func _checkAndProcessExternalChanges() {
        wasDatabaseModifiedExternally { [weak self] result in
            guard let self else { return }
            _updateAnnouncements()
            switch result {
            case let .hasChanged(behavior):
                processDatabaseChange(behavior: behavior)
            case .isTheSame:
                _maybeApplyAndSavePendingChanges(recoveryMode: false)
            }
        }
    }
}

extension DatabaseViewerCoordinator {
    private func wasDatabaseModifiedExternally(completion: @escaping (ExternalUpdateResult) -> Void) {
        guard let groupViewerVC = _topGroupViewer,
              !groupViewerVC.isEditing
        else {
            completion(.isTheSame)
            return
        }

        let dbRef: URLReference = _databaseFile.originalReference

        let behavior = DatabaseSettingsManager.shared.getExternalUpdateBehavior(dbRef)
        switch behavior {
        case .dontCheck:
            completion(.isTheSame)
            return
        case .checkAndNotify, .checkAndReload:
            break
        }

        let currentHash: FileInfo.ContentHash?
        if let fileInfo = dbRef.getCachedInfoSync(canFetch: false) {
            currentHash = fileInfo.hash
            guard currentHash != nil else {
                Diag.debug("File provider does not support content hash, skipping")
                completion(.isTheSame)
                return
            }
        } else {
            Diag.info("Current content hash unknown, but should be. Checking again")
            currentHash = nil
        }

        changeDatabaseUpdateCheckStatus(to: .inProgress)
        let timeoutDuration = DatabaseSettingsManager.shared.getFallbackTimeout(dbRef, forAutoFill: false)
        FileDataProvider.readFileInfo(
            dbRef,
            canUseCache: false,
            timeout: Timeout(duration: timeoutDuration),
            completionQueue: .main
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(info):
                guard let newHash = info.hash else {
                    changeDatabaseUpdateCheckStatus(to: .idle)
                    completion(.isTheSame)
                    return
                }
                if newHash != currentHash {
                    changeDatabaseUpdateCheckStatus(to: .idle)
                    completion(.hasChanged(behavior))
                } else {
                    Diag.info("Database is up to date")
                    changeDatabaseUpdateCheckStatus(to: .upToDate)
                    completion(.isTheSame)
                }
            case let .failure(error):
                Diag.error("Reading database file info failed [message: \(error.localizedDescription)]")
                changeDatabaseUpdateCheckStatus(to: .failed)
                completion(.isTheSame)
            }
        }
    }

    private func processDatabaseChange(behavior: ExternalUpdateBehavior) {
        _databaseUpdateCheckStatus = .idle
        switch behavior {
        case .dontCheck:
            assertionFailure("Should not happen")
        case .checkAndNotify:
            Diag.info("Database changed elsewhere, suggesting reload")
            let toastHost = _presenterForModals
            let action = ToastAction(title: LString.actionReloadDatabase) { [weak self] in
                guard let self else { return }
                toastHost.hideAllToasts()
                delegate?.didPressReloadDatabase(
                    _databaseFile,
                    currentGroupUUID: _currentGroup?.uuid,
                    in: self
                )
            }
            toastHost.showNotification(
                LString.databaseChangedExternallyMessage,
                title: nil,
                action: action
            )
        case .checkAndReload:
            Diag.info("Database changed elsewhere, reloading automatically")
            delegate?.didPressReloadDatabase(
                _databaseFile,
                currentGroupUUID: _currentGroup?.uuid,
                in: self
            )
        }
    }

    private func changeDatabaseUpdateCheckStatus(to newStatus: DatabaseUpdateCheckStatus) {
        guard newStatus != _databaseUpdateCheckStatus else {
            return
        }
        _databaseUpdateCheckTimer?.invalidate()
        _databaseUpdateCheckTimer = nil

        _databaseUpdateCheckStatus = newStatus

        switch newStatus {
        case .idle:
            break
        case .inProgress:
            break
        case .failed, .upToDate:
            _databaseUpdateCheckTimer = Timer.scheduledTimer(
                withTimeInterval: 2.0,
                repeats: false
            ) { [weak self] _ in
                self?.changeDatabaseUpdateCheckStatus(to: .idle)
            }
        }
        _topGroupViewer?.refresh(animated: true)
    }
}
