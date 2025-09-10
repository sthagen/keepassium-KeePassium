//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol WebDAVConnectionSetupCoordinatorDelegate: AnyObject {
    func didPickRemoteFile(
        url: URL,
        credential: NetworkCredential,
        in coordinator: WebDAVConnectionSetupCoordinator
    )

    func didPickRemoteFolder(
        _ folder: WebDAVItem,
        credential: NetworkCredential,
        stateIndicator: BusyStateIndicating?,
        in coordinator: WebDAVConnectionSetupCoordinator
    )
}

final class WebDAVConnectionSetupCoordinator: BaseCoordinator, RemoteConnectionSetupAlertPresenting {
    weak var delegate: WebDAVConnectionSetupCoordinatorDelegate?

    private var mode: RemoteConnectionSetupMode
    private let setupVC: WebDAVConnectionSetupVC
    private var credential: NetworkCredential?

    init(
        mode: RemoteConnectionSetupMode,
        router: NavigationRouter,
    ) {
        self.mode = mode
        self.setupVC = WebDAVConnectionSetupVC.make()
        super.init(router: router)
        setupVC.delegate = self
        switch mode {
        case .pick: break
        case .edit(let oldRef), .reauth(let oldRef):
            prefillConnectionData(from: oldRef)
        }
    }

    override func start() {
        super.start()
        _pushInitialViewController(setupVC, animated: true)
    }

    private func prefillConnectionData(from ref: URLReference) {
        guard let prefixedURL = ref.url else { return }

        let nakedURL = WebDAVFileURL.getNakedURL(from: prefixedURL)
        setupVC.webdavURL = nakedURL

        if let credential = CredentialManager.shared.get(for: prefixedURL) {
            setupVC.webdavUsername = credential.username
            setupVC.webdavPassword = credential.password
            setupVC.allowUntrustedCertificate = credential.allowUntrustedCertificate
        }
    }

    private func showFolder(
        folder: WebDAVItem,
        credential: NetworkCredential,
        stateIndicator: BusyStateIndicating
    ) {
        stateIndicator.indicateState(isBusy: true)
        WebDAVManager.shared.getItems(
            in: folder,
            credential: credential,
            timeout: Timeout(duration: FileDataProvider.defaultTimeoutDuration),
            completionQueue: .main
        ) { [weak self, weak stateIndicator] result in
            guard let self else { return }
            stateIndicator?.indicateState(isBusy: false)
            switch result {
            case .success(let items):
                showFolder(items: items, parent: folder, title: folder.name)
            case .failure(let remoteError):
                _presenterForModals.showErrorAlert(remoteError)
            }
        }
    }

    private func showFolder(
        items: [WebDAVItem],
        parent: WebDAVItem?,
        title: String
    ) {
        let vc = RemoteFolderViewerVC.make()
        vc.folder = parent
        vc.items = items
        vc.folderName = title
        vc.delegate = self
        switch mode {
        case .pick(let targetKind):
            vc.targetKind = targetKind
        case .edit:
            vc.targetKind = .file
        case .reauth:
            assertionFailure("Reauth mode tried to show folder")
            vc.targetKind = .file
        }
        _router.push(vc, animated: true, onPop: nil)
    }
}

extension WebDAVConnectionSetupCoordinator: RemoteFolderViewerDelegate {
    func canSaveTo(folder: RemoteFileItem?, in viewController: RemoteFolderViewerVC) -> Bool {
        return folder != nil
    }

    func didSelectItem(_ item: RemoteFileItem, in viewController: RemoteFolderViewerVC) {
        guard let credential else {
            Diag.warning("Not signed into WebDav, cancelling")
            assertionFailure()
            return
        }

        guard let webDAVItem = item as? WebDAVItem else {
            Diag.warning("Unexpected type of selected item")
            assertionFailure()
            return
        }

        if item.isFolder {
            showFolder(folder: webDAVItem, credential: credential, stateIndicator: viewController)
            return
        }

        let prefixedURL = WebDAVFileURL.build(nakedURL: webDAVItem.url)
        checkAndPickWebDAVConnection(
              url: prefixedURL,
              credential: credential,
              viewController: viewController)
    }

    func didPressSave(to folder: RemoteFileItem, in viewController: RemoteFolderViewerVC) {
        guard let webDAVFolder = folder as? WebDAVItem,
              let credential else {
            assertionFailure()
            return
        }

        delegate?.didPickRemoteFolder(
            webDAVFolder,
            credential: credential,
            stateIndicator: viewController,
            in: self
        )
    }
}

extension WebDAVConnectionSetupCoordinator: WebDAVConnectionSetupVCDelegate {
    func didPressDone(
        nakedWebdavURL: URL,
        credential: NetworkCredential,
        in viewController: WebDAVConnectionSetupVC
    ) {
        self.credential = credential

        if nakedWebdavURL.hasDirectoryPath {
            Diag.debug("Target URL has directory path")
            showFolder(
                folder: .root(url: nakedWebdavURL),
                credential: credential,
                stateIndicator: viewController
            )
            return
        }

        viewController.indicateState(isBusy: true)
        WebDAVManager.shared.checkItemKind(
            url: nakedWebdavURL,
            credential: credential,
            timeout: Timeout(duration: FileDataProvider.defaultTimeoutDuration),
            completionQueue: .main
        ) { [weak self, weak viewController] result in
            guard let self,
                  let viewController
            else { return }

            viewController.indicateState(isBusy: false)
            switch result {
            case .success(let remoteItemKind):
                switch remoteItemKind {
                case .folder:
                    didFindRemoteDirectory(
                        url: nakedWebdavURL,
                        credential: credential,
                        viewController: viewController
                    )
                case .file:
                    didFindRemoteFile(
                        url: nakedWebdavURL,
                        credential: credential,
                        viewController: viewController
                    )
                }
            case .failure(let error):
                viewController.showErrorAlert(error)
            }
        }
    }

    private func didFindRemoteDirectory(
        url nakedWebdavURL: URL,
        credential: NetworkCredential,
        viewController: WebDAVConnectionSetupVC
    ) {
        Diag.debug("Target URL is a directory")
        showFolder(
            folder: .root(url: nakedWebdavURL),
            credential: credential,
            stateIndicator: viewController
        )
    }

    private func didFindRemoteFile(
        url nakedWebdavURL: URL,
        credential: NetworkCredential,
        viewController: UIViewController & BusyStateIndicating
    ) {
        Diag.debug("Target URL is a file")
        switch mode {
        case .pick(let expectedItemKind):
            if expectedItemKind == .folder {
                viewController.showErrorAlert(
                    LString.Error.webDAVExportNeedsFolder,
                    title: LString.titleError
                )
                return
            }
        case .edit, .reauth:
            break
        }

        let prefixedURL = WebDAVFileURL.build(nakedURL: nakedWebdavURL)
        self.checkAndPickWebDAVConnection(
            url: prefixedURL,
            credential: credential,
            viewController: viewController
        )
    }

    private func checkAndPickWebDAVConnection(
        url: URL,
        credential: NetworkCredential,
        viewController: UIViewController & BusyStateIndicating
    ) {
        viewController.indicateState(isBusy: true)
        WebDAVManager.shared.getFileInfo(
            url: url.withoutSchemePrefix(),
            credential: credential,
            timeout: Timeout(duration: FileDataProvider.defaultTimeoutDuration),
            completion: { [weak self, weak viewController] result in
                guard let self, let viewController else { return }
                viewController.indicateState(isBusy: false)
                switch result {
                case .success:
                    Diag.info("Remote file picked successfully")
                    self.delegate?.didPickRemoteFile(url: url, credential: credential, in: self)
                    self.dismiss()
                case .failure(let fileAccessError):
                    Diag.error("Failed to access WebDAV file [message: \(fileAccessError.localizedDescription)]")
                    viewController.showErrorAlert(fileAccessError)
                }
            }
        )
    }
}
