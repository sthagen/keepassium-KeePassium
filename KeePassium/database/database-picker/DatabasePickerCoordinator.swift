//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

protocol DatabasePickerCoordinatorDelegate: AnyObject {
    func didPressShowDiagnostics(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController)
    func didPressShowAppSettings(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController)
    func didPressShowRandomGenerator(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController)

    func shouldAcceptUserSelection(
        _ fileRef: URLReference,
        in coordinator: DatabasePickerCoordinator) -> Bool

    func didSelectDatabase(
        _ fileRef: URLReference?,
        cause: ItemActivationCause?,
        in coordinator: DatabasePickerCoordinator
    )
}

extension DatabasePickerCoordinatorDelegate {
    func shouldAcceptUserSelection(
        _ fileRef: URLReference,
        in coordinator: DatabasePickerCoordinator
    ) -> Bool {
        return true
    }
    func didPressShowAppSettings(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController) {
        assertionFailure("Called a method not implemented by delegate")
    }
    func didPressShowRandomGenerator(at popoverAnchor: PopoverAnchor?, in viewController: UIViewController) {
        assertionFailure("Called a method not implemented by delegate")
    }
}

class DatabasePickerCoordinator: FilePickerCoordinator {
    weak var delegate: DatabasePickerCoordinatorDelegate?
    let mode: DatabasePickerMode

    internal var _selectedDatabase: URLReference?
    internal var _hasPendingTransactions = false
    internal var _databaseBeingEdited: URLReference?

    init(router: NavigationRouter, mode: DatabasePickerMode) {
        self.mode = mode
        let toolbarDecorator = ToolbarDecorator()
        let itemDecorator = ItemDecorator()
        super.init(
            router: router,
            fileType: .database,
            itemDecorator: itemDecorator,
            toolbarDecorator: toolbarDecorator,
            dismissButtonStyle: nil,
            appearance: .plain
        )
        title = LString.titleDatabases
        itemDecorator.coordinator = self
        toolbarDecorator.coordinator = self
    }

    public func isKnownDatabase(_ databaseRef: URLReference) -> Bool {
        let knownDatabases = _fileReferences
        return knownDatabases.contains(databaseRef)
    }

    public func canBeOpenedAutomatically(databaseRef: URLReference) -> Bool {
        let validDatabases = _fileReferences.filter {
            !$0.hasError && !$0.needsReinstatement
        }
        return validDatabases.contains(databaseRef)
    }

    public func getListedDatabaseCount() -> Int {
        return _fileReferences.count
    }

    public func getFirstListedDatabase() -> URLReference? {
        return _fileReferences.first
    }

    override func refresh() {
        _updateAnnouncements()
        super.refresh()
    }

    override func _didUpdateFileReferences() {
        super._didUpdateFileReferences()
        let hadTransactions = _hasPendingTransactions
        _hasPendingTransactions = _fileReferences.contains(where: {
            DatabaseTransactionManager.hasPendingTransaction(for: $0)
        })

        if _hasPendingTransactions != hadTransactions {
            _updateAnnouncements()
        }
    }

    override var _contentUnavailableConfiguration: UIContentUnavailableConfiguration? {
        return EmptyListConfigurator.makeConfiguration(for: self)
    }

    override func shouldAcceptUserSelection(_ fileRef: URLReference, in viewController: FilePickerVC) -> Bool {
        return delegate?.shouldAcceptUserSelection(fileRef, in: self) ?? true
    }

    override func didSelectFile(
        _ fileRef: URLReference?,
        cause: ItemActivationCause?,
        in viewController: FilePickerVC
    ) {
        guard let fileRef else {
            Diag.warning("Unexpectedly selected no database, ignoring")
            assertionFailure("DB Picker does not have no-selection option")
            return
        }
        if let cause {
            _paywallDatabaseSelection(fileRef, animated: true, in: viewController) { [weak self] fileRef in
                guard let self else { return }
                selectDatabase(fileRef, animated: true)
                delegate?.didSelectDatabase(fileRef, cause: cause, in: self)
            }
        } else {
            selectDatabase(fileRef, animated: true)
            delegate?.didSelectDatabase(fileRef, cause: nil, in: self)
        }
    }
}
