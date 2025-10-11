//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol DatabaseViewerCoordinatorDelegate: AnyObject {
    func didLeaveDatabase(in coordinator: DatabaseViewerCoordinator)

    func didRelocateDatabase(_ databaseFile: DatabaseFile, to url: URL)

    func didPressReinstateDatabase(_ fileRef: URLReference, in coordinator: DatabaseViewerCoordinator)

    func didPressReloadDatabase(
        _ databaseFile: DatabaseFile,
        currentGroupUUID: UUID?,
        in coordinator: DatabaseViewerCoordinator
    )

    func didPressSwitchTo(
        databaseRef: URLReference,
        compositeKey: CompositeKey,
        in coordinator: DatabaseViewerCoordinator
    )
}

final class DatabaseViewerCoordinator: BaseCoordinator {
    internal let vcAnimationDuration = 0.3

    weak var delegate: DatabaseViewerCoordinatorDelegate?

    static let defaultActionsManager = ActionsManager()

    public private(set) var actionsManager: ActionsManager!

    internal let _databaseFile: DatabaseFile
    internal let _database: Database
    internal let _loadingWarnings: DatabaseLoadingWarnings?

    internal var _primaryRouter: NavigationRouter { _router }
    internal var _entryViewerRouter: NavigationRouter?

    internal var _initialGroupUUID: UUID?
    internal weak var _currentGroup: Group?
    internal weak var _currentEntry: Entry?

    internal let _splitViewController: RootSplitVC
    override var _presenterForModals: UIViewController {
        _splitViewController.presentedViewController ?? _splitViewController
    }

    internal var _groupViewers = [GroupViewerVC]()
    internal var _topGroupViewer: GroupViewerVC? { _groupViewers.last }

    internal var _announcementCount = 0
    internal var _searchQuery: String?
    internal let _searchHelper = SearchHelper()
    internal var _isSearchOngoing: Bool { _searchQuery?.isNotEmpty ?? false }

    internal var _databaseLockTimer: DispatchSourceTimer!
    internal var _cachedUserActivityTimestamp: Date?

    internal var _databaseUpdateCheckTimer: Timer?
    internal var _databaseUpdateCheckStatus: DatabaseUpdateCheckStatus = .idle

    internal let _autoTypeHelper: AutoTypeHelper?
    internal lazy var faviconDownloader = FaviconDownloader()
    internal lazy var _specialEntryParser = SpecialEntryParser()

    internal var _hasUnsavedBulkChanges = false
    internal var _progressOverlay: ProgressOverlay?

    internal var databaseSaver: DatabaseSaver?
    internal var fileExportHelper: FileExportHelper?
    internal var fileImportHelper: FileImportHelper?
    internal var savingProgressHost: ProgressViewHost? { self }
    internal var saveSuccessHandler: (() -> Void)?

    internal var _canEditDatabase: Bool { !_databaseFile.status.contains(.readOnly) }
    internal var _supportsSmartGroups: Bool { _database is Database2 }
    internal var _currentGroupPermissions: DatabaseViewerItemPermissions {
        if let _currentGroup {
            return DatabaseViewerPermissionManager.getPermissions(for: _currentGroup, in: _databaseFile)
        } else {
            return []
        }
    }
    internal var _canReorderItems: Bool {
        Settings.current.groupSortOrder == .noSorting && _currentGroupPermissions.contains(.reorderItems)
    }

    init(
        splitViewController: RootSplitVC,
        primaryRouter: NavigationRouter,
        databaseFile: DatabaseFile,
        context: DatabaseReloadContext?,
        loadingWarnings: DatabaseLoadingWarnings?,
        autoTypeHelper: AutoTypeHelper?
    ) {
        self._splitViewController = splitViewController
        self._databaseFile = databaseFile
        self._database = databaseFile.database
        self._loadingWarnings = loadingWarnings
        self._autoTypeHelper = autoTypeHelper
        self._initialGroupUUID = context?.groupUUID
        super.init(router: primaryRouter)

        actionsManager = ActionsManager(coordinator: self)
    }

    override func start() {
        super.start()

        _pushInitialGroupViewers(replacingTopVC: _splitViewController.isCollapsed)
        _showEntry(nil)
        if _splitViewController.isExpanded {
            _splitViewController.show(.primary)
        }

        Settings.current.startupDatabase = _databaseFile.originalReference

        _updateUserActivityTimestamp()
        _setupDatabaseLockTimer()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2 * vcAnimationDuration) { [weak self] in
            self?._processJustOpenedDatabase()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneDidBecomeActive),
            name: UIScene.didActivateNotification,
            object: nil)
        refresh(animated: false)
    }

    deinit {
        _databaseLockTimer.cancel()
        _databaseLockTimer = nil
    }

    public func stop(animated: Bool, completion: (() -> Void)?) {
        guard let rootGroupViewer = _groupViewers.first else {
            assertionFailure("All group viewers are already deallocated")
            Diag.debug("All group viewers are already deallocated, ignoring")
            return
        }
        _primaryRouter.dismissModals(animated: animated) {
            [self, rootGroupViewer] in
            _primaryRouter.pop(
                viewController: rootGroupViewer,
                animated: animated,
                completion: completion
            )
        }
    }

    override func refresh() {
        super.refresh()
        refresh(animated: true)
    }

    func refresh(animated: Bool) {
        _updateAnnouncements()
        _updateData(searchQuery: _searchQuery)
        _topGroupViewer?.refresh(animated: animated)
        if let topSecondaryVC = _entryViewerRouter?.navigationController.topViewController {
            (topSecondaryVC as? Refreshable)?.refresh()
        }
        UIMenu.rebuildMainMenu()
    }

    override func settingsDidChange(key: Settings.Keys) {
        super.settingsDidChange(key: key)
        if key == .recentUserActivityTimestamp {
            _updateUserActivityTimestamp()
        }
    }

    public func closeDatabase(
        shouldLock: Bool,
        reason: DatabaseCloseReason,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        if shouldLock {
            Settings.current.startupDatabase = nil
            DatabaseSettingsManager.shared.updateSettings(for: _databaseFile.originalReference) {
                $0.clearMasterKey()
            }
        }
        Diag.debug("Database closed [locked: \(shouldLock), reason: \(reason)]")
        stop(animated: animated, completion: completion)
    }
}

extension DatabaseViewerCoordinator {
    @objc private func sceneDidBecomeActive(_ notification: Notification) {
        _lockDatabaseIfExpired()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?._checkAndProcessExternalChanges()
        }
    }

    private func _processJustOpenedDatabase() {
        if let loadingWarnings = _loadingWarnings,
           !loadingWarnings.isEmpty
        {
            _showLoadingWarnings(loadingWarnings)
            return
        }

        if _maybeApplyAndSavePendingChanges(recoveryMode: false) {
            return
        }

        if _announcementCount == 0 {
            StoreReviewSuggester.maybeShowAppReview(
                appVersion: AppInfo.version,
                occasion: .didOpenDatabase,
                presenter: UIApplication.shared.currentActiveScene
            )
        }
    }

    private func _showLoadingWarnings(_ warnings: DatabaseLoadingWarnings) {
        if warnings.isEmpty { return }

        DatabaseLoadingWarningsVC.present(
            warnings,
            in: _presenterForModals,
            onLockDatabase: { [weak self] in
                self?.closeDatabase(
                    shouldLock: true,
                    reason: .userRequest,
                    animated: true,
                    completion: nil
                )
            }
        )
        StoreReviewSuggester.registerEvent(.trouble)
    }

    internal func _startReordering() {
        assert(_topGroupViewer != nil)
        _topGroupViewer?.startReordering()
        refresh(animated: true)
    }

    internal func _startSelecting() {
        assert(_topGroupViewer != nil)
        _topGroupViewer?.startSelecting()
        refresh(animated: true)
    }

    internal func _reloadDatabase() {
        delegate?.didPressReloadDatabase(_databaseFile, currentGroupUUID: _currentGroup?.uuid, in: self)
    }
}
