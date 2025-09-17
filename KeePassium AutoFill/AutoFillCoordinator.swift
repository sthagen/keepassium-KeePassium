//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import AuthenticationServices
import KeePassiumLib
import LocalAuthentication
import OSLog
import UIKit
#if INTUNE
import IntuneMAMSwift
import MSAL
#endif

class AutoFillCoordinator: BaseCoordinator {
    let log = Logger(subsystem: "com.keepassium.autofill", category: "AutoFillCoordinator")

    unowned var rootController: CredentialProviderViewController
    let extensionContext: ASCredentialProviderExtensionContext

    internal var _autoFillMode: AutoFillMode? {
        didSet {
            Diag.debug("Mode: \(_autoFillMode?.debugDescription ?? "nil")")
        }
    }

    internal private(set) var hasUI = false

    internal var _isInDeviceAutoFillSettings = false

    internal unowned var _databasePickerCoordinator: DatabasePickerCoordinator!
    internal weak var _entryFinderCoordinator: EntryFinderCoordinator?
    internal weak var _databaseUnlockerCoordinator: DatabaseUnlockerCoordinator?

    internal var _serviceIdentifiers = [ASCredentialServiceIdentifier]()
    internal var _passkeyRelyingParty: String?
    internal var _passkeyClientDataHash: Data?
    internal var _passkeyRegistrationParams: PasskeyRegistrationParams?

    internal var _quickTypeDatabaseLoader: DatabaseLoader?
    internal var _quickTypeRequiredRecord: QuickTypeAutoFillRecord?

    internal var watchdog: Watchdog
    internal var _passcodeInputController: PasscodeInputVC?
    internal var _isBiometricAuthShown = false
    internal var _isPasscodeInputShown = false

    internal var _databaseSaver: DatabaseSaver?

    internal var _memoryFootprintBeforeDatabaseMiB: Float?
    internal var _databaseMemoryFootprintMiB: Float?

    #if INTUNE
    internal var _enrollmentDelegate: IntuneEnrollmentDelegateImpl?
    internal var _policyDelegate: IntunePolicyDelegateImpl?
    #endif

    private var isServicesInitialized = false
    private var isStarted = false
    private let memoryPressureSource = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical])

    init(
        rootController: CredentialProviderViewController,
        context: ASCredentialProviderExtensionContext
    ) {
        log.trace("Coordinator is initializing")
        self.rootController = rootController
        self.extensionContext = context

        let navigationController = RouterNavigationController()
        navigationController.view.backgroundColor = .clear
        let router = NavigationRouter(navigationController)

        watchdog = Watchdog.shared
        super.init(router: router)

        #if PREPAID_VERSION
        BusinessModel.type = .prepaid
        #else
        BusinessModel.type = .freemium
        #endif

        #if INTUNE
        BusinessModel.isIntuneEdition = true
        OneDriveManager.shared.setAuthProvider(MSALOneDriveAuthProvider())
        #else
        BusinessModel.isIntuneEdition = false
        #endif

        Swizzler.swizzle()
        SettingsMigrator.processAppLaunch(with: Settings.current)
        Diag.info(AppInfo.description)

        memoryPressureSource.setEventHandler { [weak self] in self?.handleMemoryWarning() }
        memoryPressureSource.activate()

        watchdog.delegate = self
    }

    deinit {
        log.trace("Coordinator is deinitializing")
        memoryPressureSource.cancel()
    }

    func initServices() {
        assert(!isStarted, "initServices() must be called before start()")
        if isServicesInitialized {
            assertionFailure("Repeated call to initServices")
            return
        }

        log.trace("Coordinator is preparing")
        let premiumManager = PremiumManager.shared
        premiumManager.reloadReceipt()
        premiumManager.usageMonitor.startInterval()
        watchdog.didBecomeActive()
        isServicesInitialized = true
    }

    override func start() {
        super.start()
        if isStarted {
            return
        } else {
            if !isServicesInitialized {
                initServices()
            }
            isStarted = true
        }

        log.trace("Coordinator is starting the UI")
        if _isInDeviceAutoFillSettings {
            rootController.showChildViewController(_router.navigationController)
            DispatchQueue.main.async { [weak self] in
                self?._showUncheckKeychainMessage()
            }
            return
        }

        if !isAppLockVisible {
            rootController.showChildViewController(_router.navigationController)
            if _isNeedsOnboarding() {
                DispatchQueue.main.async { [weak self] in
                    self?._presentOnboarding()
                }
            }
        }

        _showDatabasePicker()
        hasUI = true
        StoreReviewSuggester.registerEvent(.sessionStart)

        #if INTUNE
        setupIntune()
        guard let currentUser = IntuneMAMEnrollmentManager.instance().enrolledAccount(),
              !currentUser.isEmpty
        else {
            Diag.debug("Intune account missing, starting enrollment")
            DispatchQueue.main.async {
                self.startIntuneEnrollment()
            }
            return
        }
        Diag.info("Intune account is enrolled")
        #endif

        runAfterStartTasks()
    }

    private func runAfterStartTasks() {
        #if INTUNE
        applyIntuneAppConfig()

        guard ManagedAppConfig.shared.hasProvisionalLicense() else {
            showOrgLicensePaywall()
            return
        }
        #endif

        guard Settings.current.isAutoFillFinishedOK else {
            _showCrashReport()
            return
        }

        if let startupDatabaseRef = Settings.current.startupDatabase,
           Settings.current.isAutoUnlockStartupDatabase,
           _databasePickerCoordinator.canBeOpenedAutomatically(databaseRef: startupDatabaseRef)
        {
            _databasePickerCoordinator.selectDatabase(startupDatabaseRef, animated: true)
            _showDatabaseUnlocker(startupDatabaseRef, andThen: .unlock)
            return
        }
        if _databasePickerCoordinator.getListedDatabaseCount() == 1,
           let theOnlyDatabase = _databasePickerCoordinator.getFirstListedDatabase(),
           _databasePickerCoordinator.canBeOpenedAutomatically(databaseRef: theOnlyDatabase)
        {
            _databasePickerCoordinator.selectDatabase(theOnlyDatabase, animated: true)
            _showDatabaseUnlocker(theOnlyDatabase, andThen: .unlock)
            return
        }
    }

    public func cleanup() {
        PremiumManager.shared.usageMonitor.stopInterval()
        Watchdog.shared.willResignActive()
        _router.popToRoot(animated: false)
        removeAllChildCoordinators()
    }

    public func dismissAndQuit() {
        log.trace("Coordinator will clean up and quit")
        _cancelRequest(.userCanceled)
        Settings.current.isAutoFillFinishedOK = true
        cleanup()
    }
}

extension AutoFillCoordinator {
    private func handleMemoryWarning() {
        if memoryPressureSource.isCancelled {
            return
        }

        let mibFootprint = MemoryMonitor.getMemoryFootprintMiB()
        let event = memoryPressureSource.data
        switch event {
        case .warning:
            Diag.error(String(format: "Received a memory warning, using %.1f MiB", mibFootprint))
        case.critical:
            Diag.error(String(format: "Received a CRITICAL memory warning, using %.1f MiB", mibFootprint))
            log.warning("Received a CRITICAL memory warning, will cancel loading")
            _databaseUnlockerCoordinator?.cancelLoading(reason: .lowMemoryWarning)
        default:
            log.error("Received a memory warning of unrecognized type")
        }
    }
}
