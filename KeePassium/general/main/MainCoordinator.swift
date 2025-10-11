//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib
#if INTUNE
import IntuneMAMSwift
import MSAL
#endif

final class MainCoordinator: UIResponder, Coordinator {
    var childCoordinators = [Coordinator]()

    var _dismissHandler: CoordinatorDismissHandler? {
        didSet {
            fatalError("Don't set dismiss handler in MainCoordinator, it is never called.")
        }
    }

    internal let _rootSplitVC: RootSplitVC
    internal let _primaryRouter: NavigationRouter

    internal var _databaseUnlockerRouter: NavigationRouter?

    internal var _databasePickerCoordinator: DatabasePickerCoordinator!
    internal var _databaseViewerCoordinator: DatabaseViewerCoordinator?

    internal let _watchdog: Watchdog
    internal let _mainWindow: UIWindow
    internal var _appCoverWindow: UIWindow?
    internal var _appLockWindow: UIWindow?
    internal var _biometricsBackgroundWindow: UIWindow?
    internal var _isBiometricAuthShown = false
    internal var _isInitialAppLock = true

    internal var _lastSuccessfulBiometricAuthTime: Date = .distantPast

    #if INTUNE
    internal var _enrollmentDelegate: IntuneEnrollmentDelegateImpl?
    internal var _policyDelegate: IntunePolicyDelegateImpl?
    #endif

    internal var _selectedDatabaseRef: URLReference?

    internal var _isInitialDatabase = true

    internal var _toolbarDelegate: MainToolbarDelegate?
    internal let _autoTypeHelper: AutoTypeHelper?
    internal var _presenterForModals: UIViewController {
        _rootSplitVC.presentedViewController ?? _rootSplitVC
    }

    init(window: UIWindow, autoTypeHelper: AutoTypeHelper?) {
        self._mainWindow = window
        self._autoTypeHelper = autoTypeHelper
        self._rootSplitVC = RootSplitVC()

        _primaryRouter = NavigationRouter(RouterNavigationController())
        _rootSplitVC.setViewController(
            _primaryRouter.navigationController,
            for: .primary)

        _watchdog = Watchdog.shared
        super.init()

        _watchdog.delegate = self

        window.rootViewController = _rootSplitVC

        #if targetEnvironment(macCatalyst)
        DispatchQueue.main.async { [self] in
            _setupMacToolbar()
        }
        #endif

        _setupShakeGestureObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        assert(childCoordinators.isEmpty)
        removeAllChildCoordinators()
    }
}

extension MainCoordinator {
    internal func _setDatabase(
        _ databaseRef: URLReference?,
        autoOpenWith context: DatabaseReloadContext? = nil,
        andThen activation: DatabaseUnlockerActivationType = .doNothing
    ) {
        self._selectedDatabaseRef = databaseRef
        _databasePickerCoordinator.selectDatabase(databaseRef, animated: false)
        guard let databaseRef else {
            _rootSplitVC.setSecondaryRouter(nil)
            return
        }

        let dbUnlocker = _showDatabaseUnlocker(databaseRef, context: context)
        dbUnlocker.setDatabase(databaseRef, andThen: activation)
    }

    internal func _showDonationScreen(in viewController: UIViewController) {
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let tipBoxCoordinator = TipBoxCoordinator(router: modalRouter)
        tipBoxCoordinator.start()
        addChildCoordinator(tipBoxCoordinator, onDismiss: nil)

        viewController.present(modalRouter, animated: true, completion: nil)
    }

    internal func _showAboutScreen(
        at popoverAnchor: PopoverAnchor?,
        in viewController: UIViewController
    ) {
        let popoverAnchor = popoverAnchor ?? _mainWindow.asPopoverAnchor
        let modalRouter = NavigationRouter.createModal(
            style: ProcessInfo.isRunningOnMac ? .formSheet : .popover,
            at: popoverAnchor)
        let aboutCoordinator = AboutCoordinator(router: modalRouter)
        aboutCoordinator.start()
        addChildCoordinator(aboutCoordinator, onDismiss: nil)
        viewController.present(modalRouter, animated: true, completion: nil)
    }

    internal func _showSettingsScreen(in viewController: UIViewController) {
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let settingsCoordinator = MainSettingsCoordinator(router: modalRouter)
        settingsCoordinator.start()
        addChildCoordinator(settingsCoordinator, onDismiss: nil)
        viewController.present(modalRouter, animated: true, completion: nil)
    }

    internal func _showDiagnostics(in viewController: UIViewController, onDismiss: (() -> Void)? = nil) {
        let modalRouter = NavigationRouter.createModal(style: .formSheet)
        let diagnosticsViewerCoordinator = DiagnosticsViewerCoordinator(router: modalRouter)
        diagnosticsViewerCoordinator.start()

        viewController.present(modalRouter, animated: true, completion: nil)
        addChildCoordinator(diagnosticsViewerCoordinator, onDismiss: { [onDismiss] _ in
            onDismiss?()
        })
    }
}
