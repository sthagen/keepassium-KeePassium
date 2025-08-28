//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension MainCoordinator {
    internal func _showPlaceholder() {
        if !_rootSplitVC.isCollapsed {
            _rootSplitVC.setDetailRouter(_placeholderRouter)
        }
        _deallocateDatabaseUnlocker()
    }
}

extension MainCoordinator: UISplitViewControllerDelegate {
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        if secondaryViewController is PlaceholderVC {
            return true
        }
        if let secondaryNavVC = secondaryViewController as? UINavigationController,
           let topSecondary = secondaryNavVC.topViewController,
           topSecondary is PlaceholderVC
        {
            return true
        }

        return false
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        separateSecondaryFrom primaryViewController: UIViewController
    ) -> UIViewController? {
        if _databaseUnlockerRouter != nil {
            return _databaseUnlockerRouter?.navigationController
        }
        return _placeholderRouter.navigationController
    }

    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return _primaryRouter.navigationController
    }
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return _primaryRouter.navigationController
    }
}
