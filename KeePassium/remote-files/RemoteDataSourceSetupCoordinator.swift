//  KeePassium Password Manager
//  Copyright © 2018-2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation
import KeePassiumLib
import UIKit

protocol RemoteDataSourceSetupCoordinator<Manager>: Coordinator, RemoteFolderViewerDelegate {
    associatedtype Manager: RemoteDataSourceManager

    var router: NavigationRouter { get }
    var firstVC: UIViewController? { get set }
    var manager: Manager { get }
    var stateIndicator: BusyStateIndicating { get }
    var selectionMode: RemoteItemSelectionMode { get }
    var token: OAuthToken? { get set }

    func getModalPresenter() -> UIViewController
    func showErrorAlert(_ error: RemoteError)
    func onAuthorized(token: OAuthToken)
}

extension RemoteDataSourceSetupCoordinator {
    func getModalPresenter() -> UIViewController {
        return router.navigationController
    }

    func showErrorAlert(_ error: RemoteError) {
        getModalPresenter().showErrorAlert(error)
    }

    func dismiss() {
        guard let firstVC else {
            return
        }

        router.pop(viewController: firstVC, animated: true)
        self.firstVC = nil
    }

    func showFolder(folder: Manager.ItemType, presenter: UIViewController) {
        guard let token else {
            Diag.warning("Not signed into any \(Manager.self) account, cancelling")
            assertionFailure()
            return
        }

        stateIndicator.indicateState(isBusy: true)
        manager.getItems(
            in: folder,
            token: token,
            tokenUpdater: nil,
            completionQueue: .main
        ) { [weak self, weak presenter] result in
            guard let self, let presenter else { return }
            self.stateIndicator.indicateState(isBusy: false)
            switch result {
            case .success(let items):
                let vc = RemoteFolderViewerVC.make()
                vc.folder = folder
                vc.items = items
                vc.folderName = folder.name
                vc.delegate = self
                vc.selectionMode = selectionMode
                if self.firstVC == nil {
                    self.firstVC = vc
                }
                self.router.push(vc, animated: true, onPop: nil)
            case .failure(let remoteError):
                presenter.showErrorAlert(remoteError)
            }
        }
    }

    func startSignIn() {
        firstVC = nil
        token = nil

        stateIndicator.indicateState(isBusy: true)
        let presenter = router.navigationController
        manager.authenticate(presenter: presenter, completionQueue: .main) {
            [weak self] result in
            guard let self else { return }
            stateIndicator.indicateState(isBusy: false)
            switch result {
            case .success(let token):
                self.token = token
                self.onAuthorized(token: token)
            case .failure(let error):
                self.token = nil
                switch error {
                case .cancelledByUser:
                    break
                default:
                    self.showErrorAlert(error)
                }
            }
        }
    }

    func canSaveTo(folder: RemoteFileItem?, in viewController: RemoteFolderViewerVC) -> Bool {
        guard let folder else {
            return false
        }
        guard let itemTypeFolder = folder as? Manager.ItemType else {
            Diag.warning("Unexpected item type, ignoring")
            assertionFailure()
            return false
        }
        return itemTypeFolder.supportsItemCreation
    }

    func maybeSuggestPremium(isCorporateStorage: Bool, action: @escaping (RouterNavigationController) -> Void) {
        let presenter = router.navigationController

        if isCorporateStorage {
            performPremiumActionOrOfferUpgrade(
                for: .canUseBusinessClouds,
                allowBypass: true,
                bypassTitle: LString.actionIgnoreAndContinue,
                in: presenter
            ) {
                action(presenter)
            }
        } else {
            action(presenter)
        }
    }
}
