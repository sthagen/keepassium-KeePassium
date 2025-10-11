//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

protocol OneDriveConnectionSetupCoordinatorDelegate: AnyObject {
    func didPickRemoteFile(
        url: URL,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: OneDriveConnectionSetupCoordinator
    )
    func didPickRemoteFolder(
        _ folder: OneDriveItem,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: OneDriveConnectionSetupCoordinator
    )
}

final class OneDriveConnectionSetupCoordinator: RemoteDataSourceSetupCoordinator<OneDriveManager> {
    weak var delegate: OneDriveConnectionSetupCoordinatorDelegate?

    init(
        mode: RemoteConnectionSetupMode,
        scope: OAuthScope,
        stateIndicator: BusyStateIndicating,
        router: NavigationRouter,
    ) {
        var scope = scope
        switch mode {
        case .pick: break
        case .edit(let oldRef), .reauth(let oldRef):
            if oldRef.url?.isOneDriveAppFolderScopedURL == true {
                scope = .appFolder
            }
        }
        super.init(
            manager: OneDriveManager.shared,
            mode: mode,
            scope: scope,
            stateIndicator: stateIndicator,
            router: router)
    }

    override func onAccountInfoAcquired(_ accountInfo: OneDriveDriveInfo) {
        self._accountInfo = accountInfo
        let currentFileProvider = accountInfo.type.getMatchingFileProvider(scope: _scope)
        switch _mode {
        case .edit, .pick:
            break
        case .reauth(let oldRef):
            if let url = oldRef.url,
               oldRef.fileProvider == currentFileProvider
            {
                trySelectFile(url, onFailure: { [weak self] in
                    guard let self else { return }
                    self._mode = .edit(oldRef)
                    self.onAccountInfoAcquired(accountInfo)
                })
                return
            }
        }
        maybeSuggestPremium(isCorporateStorage: accountInfo.type.isCorporate) { [weak self] in
            self?.showWelcomeFolder()
        }
    }

    private func trySelectFile(_ fileURL: URL, onFailure: @escaping () -> Void) {
        guard let token = _token,
              let oneDriveItem = OneDriveItem.fromURL(fileURL)
        else {
            onFailure()
            return
        }
        _manager.getItemInfo(
            oneDriveItem,
            token: token,
            tokenUpdater: nil,
            timeout: Timeout(duration: FileDataProvider.defaultTimeoutDuration)
        ) { [self, onFailure] result in
            switch result {
            case .success(let oneDriveItem):
                Diag.info("Old file reference reinstated successfully")
                didSelectFile(oneDriveItem, stateIndicator: _stateIndicator)
            case .failure(let remoteError):
                Diag.debug("Failed to reinstate old file reference [message: \(remoteError.localizedDescription)]")
                onFailure()
            }
        }
    }

    private func showWelcomeFolder() {
        guard let accountInfo = _accountInfo else {
            Diag.warning("Not signed into any OneDrive account, cancelling")
            assertionFailure()
            return
        }

        switch _scope {
        case .appFolder:
            let appFolderItem = OneDriveItem.getDedicatedAppFolder(driveInfo: accountInfo)
            showFolder(folder: appFolderItem, stateIndicator: _stateIndicator)
        case .fullAccess:
            _showFolder(
                items: [
                    OneDriveItem.getPersonalFilesFolder(driveInfo: accountInfo),
                    OneDriveItem.getSharedWithMeFolder(driveInfo: accountInfo),
                ],
                parent: nil,
                title: accountInfo.type.description
            )
        }
    }

    override func didPressSave(to folder: RemoteFileItem, in viewController: RemoteFolderViewerVC) {
        guard let token = _token else {
            Diag.warning("Not signed into any OneDrive account, cancelling")
            assertionFailure()
            return
        }
        guard let oneDriveFolder = folder as? OneDriveItem else {
            Diag.warning("Unexpected type of selected remote item")
            assertionFailure()
            return
        }
        guard oneDriveFolder.isFolder else {
            Diag.warning("Selected item is not a folder")
            assertionFailure()
            return
        }
        delegate?.didPickRemoteFolder(
            oneDriveFolder,
            oauthToken: token,
            stateIndicator: viewController,
            in: self
        )
    }

    override func didSelectItem(_ item: RemoteFileItem, in viewController: RemoteFolderViewerVC) {
        guard let token = _token else {
            Diag.warning("Not signed into any OneDrive account, cancelling")
            assertionFailure()
            return
        }
        guard let oneDriveItem = item as? OneDriveItem else {
            Diag.warning("Unexpected type of selected item")
            assertionFailure()
            return
        }

        if item.isFolder {
            showFolder(folder: oneDriveItem, stateIndicator: viewController)
            return
        }

        _stateIndicator.indicateState(isBusy: true)
        _manager.updateItemInfo(
            oneDriveItem,
            freshToken: token,
            timeout: Timeout(duration: FileDataProvider.defaultTimeoutDuration),
            completionQueue: .main,
            completion: { [weak self, weak viewController] result in
                guard let self, let viewController  else { return }
                viewController.indicateState(isBusy: false)
                switch result {
                case .success(let fileItem):
                    self.onSelectedFileInfoUpdated(fileItem, in: viewController)
                case .failure(let remoteError):
                    Diag.info("Failed to update shared item [message: \(remoteError.localizedDescription)]")
                    viewController.showErrorAlert(remoteError)
                }
            }
        )
    }

    private func onSelectedFileInfoUpdated(
        _ fileItem: OneDriveItem,
        in viewController: RemoteFolderViewerVC
    ) {
        let driveType = fileItem.driveInfo.type
        let fileProvider = driveType.getMatchingFileProvider(scope: _scope)
        guard fileProvider.isAllowed else {
            Diag.error("OneDrive account type is blocked by org settings [type: \(driveType.description)]")
            viewController.showErrorAlert(FileAccessError.managedAccessDenied)
            _stateIndicator.indicateState(isBusy: false)
            return
        }
        if fileItem.driveInfo.type.isCorporate {
            performPremiumActionOrOfferUpgrade(for: .canUseBusinessClouds, in: viewController) { [weak self] in
                self?.didSelectFile(fileItem, stateIndicator: viewController)
            }
        } else {
            didSelectFile(fileItem, stateIndicator: viewController)
        }
    }

    private func didSelectFile(_ fileItem: OneDriveItem, stateIndicator: BusyStateIndicating?) {
        guard let token = _token else {
            Diag.error("Not signed into any OneDrive account, cancelling")
            assertionFailure()
            return
        }
        let fileURL = fileItem.toURL()
        delegate?.didPickRemoteFile(url: fileURL, oauthToken: token, stateIndicator: stateIndicator, in: self)
        dismiss()
    }
}
