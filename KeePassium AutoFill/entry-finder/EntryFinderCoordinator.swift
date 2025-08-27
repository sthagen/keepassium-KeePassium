//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import AuthenticationServices
import KeePassiumLib

protocol EntryFinderCoordinatorDelegate: AnyObject {
    func didLeaveDatabase(in coordinator: EntryFinderCoordinator)

    func didSelectEntry(
        _ entry: Entry,
        from databaseFile: DatabaseFile,
        rememberURL: URL?,
        clipboardIsBusy: Bool,
        in coordinator: EntryFinderCoordinator
    )

    @available(iOS 18.0, *)
    func didSelectText(
        _ text: String,
        from entry: Entry,
        databaseFile: DatabaseFile,
        rememberURL: URL?,
        in coordinator: EntryFinderCoordinator)

    func didPressReinstateDatabase(_ fileRef: URLReference, in coordinator: EntryFinderCoordinator)

    func didPressCreatePasskey(
        with params: PasskeyRegistrationParams,
        target entry: Entry?,
        databaseFile: DatabaseFile,
        presenter: UIViewController,
        in coordinator: EntryFinderCoordinator
    )
}

final class EntryFinderCoordinator: BaseCoordinator {
    enum EntrySelectionMode {
        case `default`
        case forPasskeyCreation
    }

    weak var delegate: EntryFinderCoordinatorDelegate?

    internal let _autoFillMode: AutoFillMode?
    internal let _entryFinderVC: EntryFinderVC
    internal let _databaseFile: DatabaseFile
    internal let _loadingWarnings: DatabaseLoadingWarnings?

    internal var _searchContext: AutoFillSearchContext
    internal let _searchHelper = SearchHelper()

    internal let _passkeyRegistrationParams: PasskeyRegistrationParams?

    internal var _manualCopyTimestamp: Date?

    internal var _recentEntry: Entry?

    internal var _entrySelectionMode: EntrySelectionMode = .default

    private let vcAnimationDuration = 0.3

    init(
        router: NavigationRouter,
        databaseFile: DatabaseFile,
        loadingWarnings: DatabaseLoadingWarnings?,
        searchContext: AutoFillSearchContext,
        passkeyRegistrationParams: PasskeyRegistrationParams?,
        autoFillMode: AutoFillMode?
    ) {
        self._databaseFile = databaseFile
        self._loadingWarnings = loadingWarnings
        self._searchContext = searchContext
        self._passkeyRegistrationParams = passkeyRegistrationParams
        self._autoFillMode = autoFillMode
        let itemDecorator = ItemDecorator()
        let toolbarDecorator = ToolbarDecorator()
        _entryFinderVC = EntryFinderVC(
            title: _databaseFile.visibleFileName,
            includeFields: _autoFillMode == .text,
            itemDecorator: itemDecorator,
            toolbarDecorator: toolbarDecorator
        )
        super.init(router: router)

        _entryFinderVC.delegate = self
        itemDecorator.coordinator = self
        toolbarDecorator.coordinator = self

        _recentEntry = RecentAutoFillEntryTracker.shared.getRecentEntry(from: _databaseFile)
    }

    override func start() {
        super.start()
        _router.prepareCustomTransition(
            duration: vcAnimationDuration,
            type: .fade,
            timingFunction: .easeOut
        )
        _router.push(
            _entryFinderVC,
            animated: false,
            replaceTopViewController: true,
            onPop: { [weak self] in
                guard let self else { return }
                self._dismissHandler?(self)
                self.delegate?.didLeaveDatabase(in: self)
            }
        )

        refresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 * vcAnimationDuration) { [weak self] in
            self?._showInitialMessages()
        }
    }

    func stop(animated: Bool, completion: (() -> Void)?) {
        _router.pop(viewController: _entryFinderVC, animated: animated, completion: completion)
    }

    override func refresh() {
        super.refresh()
        _updateAnnouncements()
        _updateContext()
        _updateData(_searchContext)
        _entryFinderVC.refresh()
    }

    internal func _updateContext() {
        let serviceID = _searchContext.serviceIdentifiers.first?.identifier
        let passkeyRP = _searchContext.passkeyRelyingParty
        _entryFinderVC.setContext(serviceID ?? passkeyRP)
    }
}

extension EntryFinderCoordinator {
    public func lockDatabase() {
        DatabaseSettingsManager.shared.updateSettings(for: _databaseFile.originalReference) {
            $0.clearMasterKey()
        }
        _router.pop(viewController: _entryFinderVC, animated: true)
        Diag.info("Database locked")
    }

    internal func _showInitialMessages() {
        if let _loadingWarnings, !_loadingWarnings.isEmpty {
            _showLoadingWarnings(_loadingWarnings)
            return
        }

        if let _passkeyRegistrationParams {
            assert(_autoFillMode == .passkeyRegistration)
            _showPasskeyRegistration(_passkeyRegistrationParams)
        }
    }

    internal func _showLoadingWarnings(_ warnings: DatabaseLoadingWarnings) {
        guard !warnings.isEmpty else { return }

        DatabaseLoadingWarningsVC.present(warnings, in: _entryFinderVC, onLockDatabase: lockDatabase)
        StoreReviewSuggester.registerEvent(.trouble)
    }

    internal func _notifyEntrySelected(_ entry: Entry, rememberURL: URL?) {
        let didUseManualCopy = _manualCopyTimestamp != nil
        delegate?.didSelectEntry(
            entry,
            from: _databaseFile,
            rememberURL: rememberURL,
            clipboardIsBusy: didUseManualCopy,
            in: self)
    }
}

extension EntryFinderCoordinator: EntryFinderVC.Delegate {
    func didChangeSearchQuery(_ text: String, in viewController: EntryFinderVC) {
        if _searchContext.userQuery == text {
            return
        }
        _searchContext.userQuery = text
        _updateData(_searchContext)
        refresh()
    }

    func didSelectEntry(_ entry: Entry, in viewController: EntryFinderVC) {
        switch _autoFillMode {
        case .passkeyRegistration:
            guard let params = _passkeyRegistrationParams else {
                assertionFailure()
                return
            }
            delegate?.didPressCreatePasskey(
                with: params,
                target: entry,
                databaseFile: _databaseFile,
                presenter: viewController,
                in: self
            )
        case .credentials, .oneTimeCode, .passkeyAssertion:
            _withContextURL(of: _searchContext, presenter: viewController) {
                [weak self, weak entry] contextURL in
                guard let self, let entry else { return }
                _notifyEntrySelected(entry, rememberURL: contextURL)
            }
        case .text:
            assertionFailure("Should not be called")
        case .none:
            assertionFailure()
        }
    }

    @available(iOS 18.0, *)
    func getSelectableFields(for entry: Entry, in viewController: EntryFinderVC) -> [EntryField]? {
        return _getSelectableFields(for: entry)
    }

    @available(iOS 18.0, *)
    func didSelectField(_ field: EntryField, in entry: Entry, in viewController: EntryFinderVC) {
        switch _autoFillMode {
        case .text:
            _withContextURL(of: _searchContext, presenter: viewController) {
                [weak self, weak entry] contextURL in
                guard let self, let entry else { return }
                let value = _getUpdatedFieldValue(field, of: entry)
                delegate?.didSelectText(
                    value,
                    from: entry,
                    databaseFile: _databaseFile,
                    rememberURL: contextURL,
                    in: self
                )
            }
        case .credentials, .oneTimeCode, .passkeyAssertion, .passkeyRegistration:
            assertionFailure("Unexpected mode for field selection")
        case .none:
            assertionFailure()
        }
    }
}
