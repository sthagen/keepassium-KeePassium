//  KeePassium Password Manager
//  Copyright © 2018 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit
import KeePassiumLib

class ChooseDatabaseVC: UITableViewController, Refreshable {
    private enum CellID {
        static let fileItem = "FileItemCell"
        static let noFiles = "NoFilesCell"
    }
    @IBOutlet weak var addDatabaseBarButton: UIBarButtonItem!
    
    private var _isEnabled = true
    var isEnabled: Bool {
        get { return _isEnabled }
        set {
            _isEnabled = newValue
            let alpha: CGFloat = _isEnabled ? 1.0 : 0.5
            navigationController?.navigationBar.isUserInteractionEnabled = _isEnabled
            navigationController?.navigationBar.alpha = alpha
            tableView.isUserInteractionEnabled = _isEnabled
            tableView.alpha = alpha
            if let toolbarItems = toolbarItems {
                for item in toolbarItems {
                    item.isEnabled = _isEnabled
                }
            }
        }
    }
    
    // available database files (both local and external)
    private var databaseRefs: [URLReference] = []
    
    private weak var databaseUnlocker: UnlockDatabaseVC?
    
    private var fileKeeperNotifications: FileKeeperNotifications!
    private var settingsNotifications: SettingsNotifications!
    
    // MAKE: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.preferredDisplayMode = .allVisible
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fileKeeperNotifications = FileKeeperNotifications(observer: self)
        settingsNotifications = SettingsNotifications(observer: self)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
        
        clearsSelectionOnViewWillAppear = false
        
        updateDetailView(onlyInTwoPaneMode: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let splitVC = splitViewController else { fatalError() }
        if !splitVC.isCollapsed {
            navigationItem.backBarButtonItem = UIBarButtonItem(
                image: UIImage(asset: .lockDatabaseToolbar),
                style: .done,
                target: nil,
                action: nil
            )
        }
        databaseUnlocker = nil
        updateDetailView(onlyInTwoPaneMode: true)
        settingsNotifications.startObserving()
        fileKeeperNotifications.startObserving()
        processPendingFileOperations()
        refresh()
    }

    override func viewDidDisappear(_ animated: Bool) {
        fileKeeperNotifications.stopObserving()
        settingsNotifications.stopObserving()
        super.viewDidDisappear(animated)
    }
    
    /// Ensures the detail VC is synchronized with the master VC.
    func updateDetailView(onlyInTwoPaneMode: Bool) {
        refresh()

        if onlyInTwoPaneMode && (splitViewController?.isCollapsed ?? true) { return }

        if databaseRefs.isEmpty {
            databaseUnlocker = nil
            showDetailViewController(WelcomeVC.make(), sender: self)
            return
        }

        if let databaseUnlocker = databaseUnlocker {
            // there is an UnlockDatabaseVC in the detail panel
            if !databaseRefs.contains(databaseUnlocker.databaseRef) {
                // and it shows a database which is not in the left list anymore
                tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
                showDetailViewController(PlaceholderVC.make(), sender: self)
                return
            }
        }
        
        guard let startDatabase = Settings.current.startupDatabase,
            let selRow = databaseRefs.index(of: startDatabase) else
        {
            tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
            return
        }

        let selectIndexPath = IndexPath(row: selRow, section: 0)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.selectRow(at: selectIndexPath, animated: true, scrollPosition: .none)
            self?.didSelectDatabase(urlRef: startDatabase)
        }
    }
    
    /// Reloads the list of available DB files
    @objc func refresh() {
        databaseRefs = FileKeeper.shared.getAllReferences(
            fileType: .database,
            includeBackup: Settings.current.isBackupFilesVisible)
        sortFileList()
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }
    }
    
    func sortFileList() {
        let fileSortOrder = Settings.current.filesSortOrder
        databaseRefs.sort { return fileSortOrder.compare($0, $1) }
        tableView.reloadData()
    }
    
    // MARK: - Action handlers
    
    @IBAction func didPressSortButton(_ sender: Any) {
        let vc = SettingsFileSortingVC.make(popoverFromBar: sender as? UIBarButtonItem)
        present(vc, animated: true, completion: nil)
    }

    @IBAction func didPressSettingsButton(_ sender: Any) {
        let settingsVC = SettingsVC.make(popoverFromBar: sender as? UIBarButtonItem)
        present(settingsVC, animated: true, completion: nil)
    }
    
    @IBAction func didPressHelpButton(_ sender: Any) {
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        let aboutVC = AboutVC.make()
        showDetailViewController(aboutVC, sender: self)
    }
    
    @IBAction func didPressAddDatabase(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: LString.actionCreateDatabase, style: .default) {
            [weak self] _ in
            self?.didPressCreateDatabase()
        })
        
        actionSheet.addAction(UIAlertAction(title: LString.actionOpenDatabase, style: .default) {
            [weak self] _ in
            self?.didPressOpenDatabase()
        })
        
        actionSheet.addAction(UIAlertAction(
            title: LString.actionCancel,
            style: .cancel,
            handler: nil)
        )
            
        if let popover = actionSheet.popoverPresentationController {
            popover.barButtonItem = addDatabaseBarButton
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    func didPressOpenDatabase() {
        let picker = UIDocumentPickerViewController(
            documentTypes: FileType.publicDataUTIs,
            in: .open)
        picker.delegate = self
        picker.modalPresentationStyle = .pageSheet
        present(picker, animated: true, completion: nil)
    }
    
    var databaseCreatorCoordinator: DatabaseCreatorCoordinator?
    func didPressCreateDatabase() {
        let navVC = UINavigationController()
        navVC.modalPresentationStyle = .formSheet
        
        assert(databaseCreatorCoordinator == nil)
        databaseCreatorCoordinator = DatabaseCreatorCoordinator(navigationController: navVC)
        databaseCreatorCoordinator!.delegate = self
        databaseCreatorCoordinator!.start()
        present(navVC, animated: true)
    }

    func didPressExportDatabase(at indexPath: IndexPath) {
        let urlRef = databaseRefs[indexPath.row]
        do {
            let url = try urlRef.resolve()
            let exportSheet = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil)
            if let popover = exportSheet.popoverPresentationController {
                guard let sourceView = tableView.cellForRow(at: indexPath) else {
                    assertionFailure()
                    return
                }
                popover.sourceView = sourceView
                popover.sourceRect = CGRect(
                    x: sourceView.bounds.width,
                    y: sourceView.center.y,
                    width: 0,
                    height: 0)
            }
            present(exportSheet, animated: true, completion: nil)
        } catch {
            Diag.error("Failed to resolve URL reference [message: \(error.localizedDescription)]")
            let alert = UIAlertController.make(
                title: LString.titleExportError,
                message: error.localizedDescription)
            present(alert, animated: true, completion: nil)
        }
    }
        
    func didPressDeleteDatabase(at indexPath: IndexPath) {
        let urlRef = databaseRefs[indexPath.row]
        let info = urlRef.getInfo()
        if info.hasError {
            // dead reference, just remove it without confirmation
            removeDatabaseFile(urlRef: urlRef)
            return
        }
        
        let message: String
        let destructiveAction: UIAlertAction
        if urlRef.location.isInternal {
            message = LString.confirmDatabaseDeletion
            destructiveAction = UIAlertAction(
                title: LString.actionDeleteFile,
                style: .destructive)
            {
                [unowned self] _ in
                
                // disable auto-open of startup database, which interferes with mass deletions
                Settings.current.startupDatabase = nil
                self.updateDetailView(onlyInTwoPaneMode: true)
                self.deleteDatabaseFile(urlRef: urlRef)
            }
        } else {
            message = LString.confirmDatabaseRemoval
            destructiveAction = UIAlertAction(title: LString.actionRemoveFile, style: .destructive)
            {
                [unowned self] _ in
                // disable auto-open of startup database, which interferes with mass deletions
                Settings.current.startupDatabase = nil
                self.updateDetailView(onlyInTwoPaneMode: true)
                self.removeDatabaseFile(urlRef: urlRef)
            }
        }
        let confirmationAlert = UIAlertController.make(
            title: info.fileName,
            message: message,
            cancelButtonTitle: LString.actionCancel)
        confirmationAlert.addAction(destructiveAction)
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    private func didSelectDatabase(urlRef: URLReference) {
        Settings.current.startupDatabase = urlRef
        let unlockDatabaseVC = UnlockDatabaseVC.make(databaseRef: urlRef)
        showDetailViewController(unlockDatabaseVC, sender: self)
        databaseUnlocker = unlockDatabaseVC
    }

    // MARK: - Removals

    private func deleteDatabaseFile(urlRef: URLReference) {
        if urlRef == Settings.current.startupDatabase {
            Settings.current.startupDatabase = nil
        }

        try? Keychain.shared.removeDatabaseKey(databaseRef: urlRef) // throws KeychainError, ignored
        do {
            let fileInfo = urlRef.getInfo()
            try FileKeeper.shared.deleteFile(
                urlRef,
                fileType: .database,
                ignoreErrors: fileInfo.hasError)
                // throws `FileKeeperError`
            refresh()
        } catch {
            Diag.error("Failed to delete database file [reason: \(error.localizedDescription)]")
            let errorAlert = UIAlertController.make(
                title: LString.titleError,
                message: error.localizedDescription)
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    private func removeDatabaseFile(urlRef: URLReference) {
        if urlRef == Settings.current.startupDatabase {
            Settings.current.startupDatabase = nil
        }
        try? Keychain.shared.removeDatabaseKey(databaseRef: urlRef) // throws KeychainError, ignored
        FileKeeper.shared.removeExternalReference(urlRef, fileType: .database)
    }
    
    /// Adds pending files, if any
    private func processPendingFileOperations() {
        FileKeeper.shared.processPendingOperations(
            success: nil,
            error: {
                [weak self] (error) in
                guard let _self = self else { return }
                let alert = UIAlertController.make(
                    title: LString.titleError,
                    message: error.localizedDescription)
                _self.present(alert, animated: true, completion: nil)
            }
        )
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databaseRefs.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell
    {
        guard databaseRefs.count > 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.noFiles, for: indexPath)
            return cell
        }
   
        let cell = tableView
            .dequeueReusableCell(withIdentifier: CellID.fileItem, for: indexPath)
            as! DatabaseFileListCell
        cell.urlRef = databaseRefs[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if splitViewController?.isCollapsed ?? false {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let selectedRef = databaseRefs[indexPath.row]
        didSelectDatabase(urlRef: selectedRef)
    }
    
    override func tableView(
        _ tableView: UITableView,
        accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        let urlRef = databaseRefs[indexPath.row]
        guard let cell = tableView.cellForRow(at: indexPath) else { assertionFailure(); return }
        let databaseInfoVC = FileInfoVC.make(urlRef: urlRef, popoverSource: cell)
        present(databaseInfoVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath
        ) -> [UITableViewRowAction]?
    {
        let shareAction = UITableViewRowAction(
            style: .default,
            title: LString.actionExport)
        {
            [unowned self] (_,_) in
            self.setEditing(false, animated: true)
            self.didPressExportDatabase(at: indexPath)
        }
        shareAction.backgroundColor = UIColor.actionTint
        
        // For deletion, the action name depends on where that file is.
        let urlRef = databaseRefs[indexPath.row]
        let fileInfo = urlRef.getInfo()
        let deleteActionTitle: String
        if urlRef.location == .external || fileInfo.hasError {
            deleteActionTitle = LString.actionRemoveFile
        } else {
            deleteActionTitle = LString.actionDeleteFile
        }
        
        let deleteAction = UITableViewRowAction(
            style: .destructive,
            title: deleteActionTitle)
        {
            [unowned self] (_,_) in
            self.setEditing(false, animated: true)
            self.didPressDeleteDatabase(at: indexPath)
        }
        deleteAction.backgroundColor = UIColor.destructiveTint
        
        return [deleteAction, shareAction]
    }
}

extension ChooseDatabaseVC: SettingsObserver {
    func settingsDidChange(key: Settings.Keys) {
        if key == .filesSortOrder || key == .backupFilesVisible {
            sortFileList()
        }
    }
}

extension ChooseDatabaseVC: FileKeeperObserver {
    func fileKeeper(didAddFile urlRef: URLReference, fileType: FileType) {
        guard fileType == .database else { return }
        Settings.current.startupDatabase = urlRef
        updateDetailView(onlyInTwoPaneMode: false)
    }

    func fileKeeper(didRemoveFile urlRef: URLReference, fileType: FileType) {
        guard fileType == .database else { return }
        updateDetailView(onlyInTwoPaneMode: false)
    }

    func fileKeeperHasPendingOperation() {
        processPendingFileOperations()
    }
}

extension ChooseDatabaseVC: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL])
    {
        guard let url = urls.first else { return }
        guard FileType.isDatabaseFile(url: url) else {
            let fileName = url.lastPathComponent
            let errorAlert = UIAlertController.make(
                title: LString.titleWarning,
                message: NSLocalizedString(
                    "Selected file \"\(fileName)\" does not look like a database.",
                    comment: "Warning when trying to add a file"),
                cancelButtonTitle: LString.actionOK)
            present(errorAlert, animated: true, completion: nil)
            return
        }
        
        switch controller.documentPickerMode {
        case .open:
            FileKeeper.shared.prepareToAddFile(url: url, mode: .openInPlace)
        case .import:
            FileKeeper.shared.prepareToAddFile(url: url, mode: .import)
        default:
            assertionFailure("Unexpected document picker mode")
        }
        processPendingFileOperations()
    }
}

// MARK: - DatabaseCreatorCoordinatorDelegate
extension ChooseDatabaseVC: DatabaseCreatorCoordinatorDelegate {
    func didPressCancel(in databaseCreatorCoordinator: DatabaseCreatorCoordinator) {
        presentedViewController?.dismiss(animated: true) { // strong self
            self.databaseCreatorCoordinator = nil
        }
    }
    
    func didCreateDatabase(
        in databaseCreatorCoordinator: DatabaseCreatorCoordinator,
        database urlRef: URLReference)
    {
        presentedViewController?.dismiss(animated: true) { // strong self
            self.databaseCreatorCoordinator = nil
        }
        Settings.current.startupDatabase = urlRef
        updateDetailView(onlyInTwoPaneMode: false)
    }
}
