//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryCreatorCoordinator {
    final class ToolbarDecorator: EntryCreatorToolbarDecorator {
        weak var coordinator: EntryCreatorCoordinator?

        func getToolbarItems() -> [UIBarButtonItem]? {
            return nil
        }

        func getLeftBarButtonItems() -> [UIBarButtonItem]? {
            let cancelButton = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction {
                [weak coordinator] _ in
                coordinator?.didPressCancel()
            })
            return [cancelButton]
        }

        func getRightBarButtonItems() -> [UIBarButtonItem]? {
            guard let coordinator else { return nil }
            var buttons = [UIBarButtonItem]()
            if PremiumManager.shared.isAvailable(feature: .canCreateEntriesInAutoFill) {
                let doneButton = UIBarButtonItem(systemItem: .done, primaryAction: UIAction {
                    [weak coordinator] _ in
                    coordinator?.didPressDone()
                })
                doneButton.isEnabled = coordinator._isEntryDataEnough
                buttons.append(doneButton)
            } else {
                let premiumButton = UIBarButtonItem(
                    title: LString.actionUpgradeToPremium,
                    image: .premiumBadge,
                    primaryAction: UIAction { [weak coordinator] _ in
                        coordinator?.didPressDone()
                    }
                )
                premiumButton.style = .done
                buttons.append(premiumButton)
            }
            return buttons
        }
    }
}

extension EntryCreatorCoordinator {
    fileprivate func didPressCancel() {
        _router.pop(viewController: _entryCreatorVC, animated: true)
    }
    fileprivate func didPressDone() {
        self.didPressDone(in: _entryCreatorVC)
    }
}
