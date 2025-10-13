//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol RemoteFilePickerCoordinatorDelegate: AnyObject {
    func didPickRemoteFile(
        url: URL,
        credential: NetworkCredential,
        in coordinator: RemoteFilePickerCoordinator
    )
    func didSelectSystemFilePicker(
        in coordinator: RemoteFilePickerCoordinator
    )
}

final class RemoteFilePickerCoordinator: BaseCoordinator {
    weak var delegate: RemoteFilePickerCoordinatorDelegate?

    private let mode: RemoteConnectionSetupMode
    private let connectionTypePicker: ConnectionTypePickerVC

    init(mode: RemoteConnectionSetupMode, router: NavigationRouter) {
        self.mode = mode
        self.connectionTypePicker = ConnectionTypePickerVC()
        super.init(router: router)
        connectionTypePicker.delegate = self
        connectionTypePicker.showsOtherLocations = true
    }

    override func start() {
        super.start()

        let connectionType: RemoteConnectionType?
        switch mode {
        case .pick:
            connectionType = nil
        case .edit(let oldRef), .reauth(let oldRef):
            connectionType = getConnectionType(by: oldRef.fileProvider)
        }

        let animated = (connectionType == nil)
        _pushInitialViewController(connectionTypePicker, dismissButtonStyle: .cancel, animated: animated)
        if let connectionType {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                didSelect(connectionType: connectionType, in: connectionTypePicker)
            }
        }
    }

    override func refresh() {
        super.refresh()
        connectionTypePicker.refresh()
    }

    private func getConnectionType(by fileProvider: FileProvider?) -> RemoteConnectionType? {
        switch fileProvider {
        case .keepassiumWebDAV:
            return .genericWebDAV
        case .keepassiumDropboxPersonal:
            return .dropboxPersonal(scope: .fullAccess)
        case .keepassiumDropboxPersonalAppFolder:
            return .dropboxPersonal(scope: .appFolder)
        case .keepassiumDropboxBusiness:
            return .dropboxBusiness(scope: .fullAccess)
        case .keepassiumDropboxBusinessAppFolder:
            return .dropboxBusiness(scope: .appFolder)
        case .keepassiumGoogleDrive:
            return .googleDrive(scope: .fullAccess)
        case .keepassiumGoogleDriveAppFolder:
            return .googleDrive(scope: .appFolder)
        case .keepassiumOneDrivePersonal:
            return .oneDrivePersonal(scope: .fullAccess)
        case .keepassiumOneDrivePersonalAppFolder:
            return .oneDrivePersonal(scope: .appFolder)
        case .keepassiumOneDriveBusiness:
            return .oneDriveForBusiness(scope: .fullAccess)
        case .keepassiumOneDriveBusinessAppFolder:
            return .oneDriveForBusiness(scope: .appFolder)
        default:
            return nil
        }
    }
}

extension RemoteFilePickerCoordinator: ConnectionTypePickerDelegate {
    func shouldSelect(
        connectionType: RemoteConnectionType,
        in viewController: ConnectionTypePickerVC
    ) -> Bool {
        if connectionType.isPremiumUpgradeRequired {
            offerPremiumUpgrade(for: .canUseBusinessClouds, in: viewController)
            return false
        }
        return true
    }

    func didSelect(connectionType: RemoteConnectionType, in viewController: ConnectionTypePickerVC) {
        switch connectionType {
        case .genericWebDAV,
             .genericHTTP,
             .hetzner,
             .hiDriveIonos,
             .hiDriveStrato,
             .koofr,
             .magentaCloud,
             .nextcloud,
             .owncloud,
             .qnap,
             .synology,
             .woelkli:
            startWebDAVSetup(connectionType: connectionType, stateIndicator: viewController)
        case .oneDrivePersonal(let scope), .oneDriveForBusiness(let scope):
            startOneDriveSetup(scope: scope, stateIndicator: viewController)
        case .dropboxPersonal(let scope), .dropboxBusiness(let scope):
            startDropboxSetup(scope: scope, stateIndicator: viewController)
        case .googleDrive(let scope), .googleWorkspace(let scope):
            startGoogleDriveSetup(scope: scope, stateIndicator: viewController)
        }
    }

    func didSelectOtherLocations(in viewController: ConnectionTypePickerVC) {
        dismiss { [self] in
            delegate?.didSelectSystemFilePicker(in: self)
        }
    }
}

extension RemoteFilePickerCoordinator: WebDAVConnectionSetupCoordinatorDelegate {
    private func startWebDAVSetup(connectionType: RemoteConnectionType, stateIndicator: BusyStateIndicating) {
        let setupCoordinator = WebDAVConnectionSetupCoordinator(
            mode: mode,
            connectionType: connectionType,
            router: _router
        )
        setupCoordinator.delegate = self
        setupCoordinator.start()
        addChildCoordinator(setupCoordinator, onDismiss: nil)
    }

    func didPickRemoteFile(
        url: URL,
        credential: NetworkCredential,
        in coordinator: WebDAVConnectionSetupCoordinator
    ) {
        delegate?.didPickRemoteFile(url: url, credential: credential, in: self)
        dismiss()
    }

    func didPickRemoteFolder(
        _ folder: WebDAVItem,
        credential: NetworkCredential,
        stateIndicator: (any BusyStateIndicating)?,
        in coordinator: WebDAVConnectionSetupCoordinator
    ) {
        assertionFailure("Expected didPickRemoteItem instead")
    }
}

extension RemoteFilePickerCoordinator: GoogleDriveConnectionSetupCoordinatorDelegate {
    private func startGoogleDriveSetup(scope: OAuthScope, stateIndicator: BusyStateIndicating) {
        let setupCoordinator = GoogleDriveConnectionSetupCoordinator(
            mode: mode,
            scope: scope,
            stateIndicator: stateIndicator,
            router: _router,
        )
        setupCoordinator.delegate = self
        setupCoordinator.start()
        addChildCoordinator(setupCoordinator, onDismiss: nil)
    }

    func didPickRemoteFile(
        url: URL,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: GoogleDriveConnectionSetupCoordinator
    ) {
        let credential = NetworkCredential(oauthToken: oauthToken)
        delegate?.didPickRemoteFile(url: url, credential: credential, in: self)
        dismiss()
    }

    func didPickRemoteFolder(
        _ folder: GoogleDriveItem,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: GoogleDriveConnectionSetupCoordinator
    ) {
        assertionFailure("Expected didPickRemoteItem instead")
    }
}

extension RemoteFilePickerCoordinator: DropboxConnectionSetupCoordinatorDelegate {
    private func startDropboxSetup(scope: OAuthScope, stateIndicator: BusyStateIndicating) {
        let setupCoordinator = DropboxConnectionSetupCoordinator(
            mode: mode,
            scope: scope,
            stateIndicator: stateIndicator,
            router: _router,
        )
        setupCoordinator.delegate = self
        setupCoordinator.start()
        addChildCoordinator(setupCoordinator, onDismiss: nil)
    }

    func didPickRemoteFile(
        url: URL,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: DropboxConnectionSetupCoordinator
    ) {
        let credential = NetworkCredential(oauthToken: oauthToken)
        delegate?.didPickRemoteFile(url: url, credential: credential, in: self)
        dismiss()
    }

    func didPickRemoteFolder(
        _ folder: DropboxItem,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: DropboxConnectionSetupCoordinator
    ) {
        assertionFailure("Expected didPickRemoteItem instead")
    }
}

extension RemoteFilePickerCoordinator: OneDriveConnectionSetupCoordinatorDelegate {
    private func startOneDriveSetup(scope: OAuthScope, stateIndicator: BusyStateIndicating) {
        let setupCoordinator = OneDriveConnectionSetupCoordinator(
            mode: mode,
            scope: scope,
            stateIndicator: stateIndicator,
            router: _router
        )
        setupCoordinator.delegate = self
        setupCoordinator.start()
        addChildCoordinator(setupCoordinator, onDismiss: nil)
    }

    func didPickRemoteFile(
        url: URL,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: OneDriveConnectionSetupCoordinator
    ) {
        let credential = NetworkCredential(oauthToken: oauthToken)
        delegate?.didPickRemoteFile(url: url, credential: credential, in: self)
        dismiss()
    }

    func didPickRemoteFolder(
        _ folder: OneDriveItem,
        oauthToken: OAuthToken,
        stateIndicator: BusyStateIndicating?,
        in coordinator: OneDriveConnectionSetupCoordinator
    ) {
        assertionFailure("Expected didPickRemoteItem instead")
    }
}
