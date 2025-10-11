//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

class RootSplitVC: UISplitViewController {
    override var delegate: (any UISplitViewControllerDelegate)? {
        didSet { fatalError("Can't touch this, used internally") }
    }

    public var isExpanded: Bool { !isCollapsed }

    private let placeholderRouter: NavigationRouter

    private weak var secondaryRouter: NavigationRouter?

    init() {
        let placeholderVC = PlaceholderVC.instantiateFromStoryboard()
        placeholderRouter = NavigationRouter(RouterNavigationController(rootViewController: placeholderVC))

        super.init(style: .doubleColumn)
        super.delegate = self
        preferredSplitBehavior = .tile
        preferredDisplayMode = .oneBesideSecondary
        displayModeButtonVisibility = .automatic
        setViewController(placeholderVC.navigationController, for: .secondary)

        maximumPrimaryColumnWidth = 700
        if ProcessInfo.isRunningOnMac {
            preferredPrimaryColumnWidthFraction = Settings.current.primaryPaneWidthFraction
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if ProcessInfo.isRunningOnMac {
            Settings.current.primaryPaneWidthFraction = primaryColumnWidth / view.bounds.width
        }
    }

    public func setSecondaryRouter(_ router: NavigationRouter?) {
        guard router !== self.secondaryRouter else {
            if router !== placeholderRouter {
                show(.secondary)
            }
            return
        }

        let newRouter = router ?? placeholderRouter
        setViewController(newRouter.navigationController, for: .secondary)

        if let oldSecondaryRouter = self.secondaryRouter,
           oldSecondaryRouter !== placeholderRouter
        {
            oldSecondaryRouter.popAll()
        }
        self.secondaryRouter = newRouter
        if newRouter !== placeholderRouter {
            show(.secondary)
        }
    }
}

extension RootSplitVC: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        let secondaryVC = svc.viewController(for: .secondary)
        if proposedTopColumn == .secondary && secondaryVC == placeholderRouter.navigationController {
            return .primary
        }
        return proposedTopColumn
    }
}
