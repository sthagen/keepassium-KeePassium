//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

class FilePickerCoordinator: BaseCoordinator, FilePickerVC.Delegate {
    internal var _contentUnavailableConfiguration: UIContentUnavailableConfiguration? { nil }
    internal var noSelectionItem: FilePickerItem.TitleImage? {
        didSet {
            _filePickerVC.setNoSelectionItem(noSelectionItem)
        }
    }
    internal var announcements: [AnnouncementItem] = [] {
        didSet {
            _filePickerVC.setAnnouncements(announcements)
        }
    }
    internal var title: String? {
        get { _filePickerVC.title }
        set { _filePickerVC.title = newValue }
    }

    internal var _fileReferences = [URLReference]()
    private let fileType: FileType
    private var fileKeeperNotifications: FileKeeperNotifications!
    private let fileInfoReloader = FileInfoReloader()

    internal let _dismissButtonStyle: UIBarButtonItem.SystemItem?

    internal let _filePickerVC: FilePickerVC

    init(
        router: NavigationRouter,
        fileType: FileType,
        itemDecorator: FilePickerItemDecorator?,
        toolbarDecorator: FilePickerToolbarDecorator?,
        dismissButtonStyle: UIBarButtonItem.SystemItem?,
        appearance: FilePickerAppearance
    ) {
        self.fileType = fileType
        _filePickerVC = FilePickerVC(
            fileType: fileType,
            toolbarDecorator: toolbarDecorator,
            itemDecorator: itemDecorator,
            appearance: appearance
        )
        self._dismissButtonStyle = dismissButtonStyle
        super.init(router: router)
        _filePickerVC.delegate = self
        fileKeeperNotifications = FileKeeperNotifications(observer: self)
    }

    deinit {
        fileKeeperNotifications.stopObserving()
    }

    override func start() {
        super.start()
        _pushInitialViewController(_filePickerVC, dismissButtonStyle: _dismissButtonStyle, animated: true)
        refresh()
        fileKeeperNotifications.startObserving()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneDidBecomeActive),
            name: UIScene.didActivateNotification,
            object: nil)
    }

    @objc private func sceneDidBecomeActive(_ sender: AnyObject?) {
        refresh()
    }

    override func refresh() {
        super.refresh()

        _fileReferences = FileKeeper.shared.getAllReferences(
            fileType: fileType,
            includeBackup: Settings.current.isBackupFilesVisible)

        let sortOrder = Settings.current.filesSortOrder
        _fileReferences.sort { sortOrder.compare($0, $1) }

        showFileRefs(_fileReferences)

        fileInfoReloader.getInfo(
            for: _fileReferences,
            update: { [weak self] _ in
                guard let self else { return }
                showFileRefs(self._fileReferences)
            },
            completion: { [weak self] in
                guard let self else { return }
                showFileRefs(self._fileReferences)
            }
        )
        _filePickerVC.refreshControls()
    }

    internal func _didUpdateFileReferences() {
    }

    private func showFileRefs(_ refs: [URLReference]) {
        _didUpdateFileReferences()
        _filePickerVC.contentUnavailableConfiguration = refs.isEmpty ? _contentUnavailableConfiguration : nil
        _filePickerVC.setFileRefs(refs)
    }

    @discardableResult
    func becomeFirstResponder() -> Bool {
        return _filePickerVC.becomeFirstResponder()
    }

    public func setEnabled(_ enabled: Bool) {
        _filePickerVC.setEnabled(enabled)
    }

    public func selectFile(_ fileRef: URLReference?, animated: Bool) {
        _filePickerVC.selectFile(fileRef, animated: animated)
    }

    func needsRefresh(_ viewController: FilePickerVC) {
        refresh()
    }

    func shouldAcceptUserSelection(_ fileRef: URLReference, in viewController: FilePickerVC) -> Bool {
        return true
    }

    func didSelectFile(
        _ fileRef: URLReference?,
        cause: ItemActivationCause?,
        in viewController: FilePickerVC
    ) {
        assertionFailure("Pure virtual method, override this")
    }

    func didEliminateFile(_ fileRef: URLReference, in coordinator: FilePickerCoordinator) {
    }
}

extension FilePickerCoordinator: FileKeeperObserver {
    func fileKeeperDidUpdate() {
        refresh()
    }
}
