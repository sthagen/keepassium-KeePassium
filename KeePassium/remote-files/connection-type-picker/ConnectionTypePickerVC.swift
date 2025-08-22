//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol ConnectionTypePickerDelegate: AnyObject {
    func shouldSelect(connectionType: RemoteConnectionType, in viewController: ConnectionTypePickerVC) -> Bool

    func didSelect(connectionType: RemoteConnectionType, in viewController: ConnectionTypePickerVC)
    func didSelectOtherLocations(in viewController: ConnectionTypePickerVC)
}

final class ConnectionTypePickerVC: UIViewController, Refreshable, BusyStateIndicating {

    internal typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    internal typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>
    internal enum Section: Hashable {
        case remoteConnections(header: String?, footer: String?)
        case otherLocations(header: String?, footer: String?)
    }

    internal enum Item: Hashable {
        case service(service: RemoteConnectionType.Service, status: Status)
        case remoteConnection(RemoteConnectionType, status: Status)
        case systemPicker(status: Status)

        struct Status: Hashable {
            var isAllowed: Bool
            var isBusy: Bool
            var needsPremium: Bool
        }
    }

    public weak var delegate: ConnectionTypePickerDelegate?

    public var showsOtherLocations = false {
        didSet {
            _applySnapshot(animated: false)
        }
    }

    internal var _dataSource: DataSource!
    internal var _collectionView: UICollectionView!
    internal var _expandedItems = Set<Item>()

    internal var _isBusy = false
    private lazy var titleView: SpinnerLabel = {
        let view = SpinnerLabel(frame: .zero)
        view.label.text = LString.titleConnection
        view.label.font = .preferredFont(forTextStyle: .headline)
        view.spinner.startAnimating()
        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .systemBackground
        navigationItem.titleView = titleView
        navigationItem.title = titleView.label.text
        _setupCollectionView()
        _setupDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func refresh() {
        _applySnapshot(animated: false)
    }

    public func indicateState(isBusy: Bool) {
        titleView.showSpinner(isBusy, animated: true)
        self._isBusy = isBusy
        refresh()
    }
}

extension ConnectionTypePickerVC {
    override var keyCommands: [UIKeyCommand]? {
        let enterKey = UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(didPressEnter))
        return [enterKey] + (super.keyCommands ?? [])
    }

    @objc private func didPressEnter() {
        guard let selectedIndexPath = _collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        _handlePrimaryAction(at: selectedIndexPath, cause: .keyPress)
    }

    internal func _handlePrimaryAction(at indexPath: IndexPath, cause: ItemActivationCause) {
        guard let selectedItem = _dataSource.itemIdentifier(for: indexPath),
              let section = _dataSource.sectionIdentifier(for: indexPath.section)
        else {
            assertionFailure()
            return
        }
        if cause == .touch {
            _collectionView.deselectItem(at: indexPath, animated: true)
        }

        switch selectedItem {
        case let .service(_, status):
            if !status.isAllowed {
                showManagedSettingNotification(text: LString.Error.storageAccessDeniedByOrg)
                return
            }
            _toggleExpanded(selectedItem, section: section)
        case let .remoteConnection(connectionType, status):
            if !status.isAllowed {
                showManagedSettingNotification(text: LString.Error.storageAccessDeniedByOrg)
                return
            }
            let canSelect = delegate?.shouldSelect(connectionType: connectionType, in: self) ?? false
            guard canSelect else {
                return
            }
            delegate?.didSelect(connectionType: connectionType, in: self)
        case let .systemPicker(status):
            if !status.isAllowed {
                showManagedSettingNotification(text: LString.Error.storageAccessDeniedByOrg)
                return
            }
            Diag.debug("Switching to system file picker")
            delegate?.didSelectOtherLocations(in: self)
        }
    }
}

extension ConnectionTypePickerVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return _isSelectableCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return _isSelectableCell(at: indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        canPerformPrimaryActionForItemAt indexPath: IndexPath
    ) -> Bool {
        return _isSelectableCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        _handlePrimaryAction(at: indexPath, cause: .touch)
    }
}
