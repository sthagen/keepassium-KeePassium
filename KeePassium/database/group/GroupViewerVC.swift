//  KeePassium Password Manager
//  Copyright © 2018–2024 KeePassium Labs <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol GroupViewerDelegate: AnyObject {
    func didPressLockDatabase(in viewController: GroupViewerVC)
    func didPressChangeMasterKey(in viewController: GroupViewerVC)
    func didPressPrintDatabase(in viewController: GroupViewerVC)
    func didPressReloadDatabase(at popoverAnchor: PopoverAnchor, in viewController: GroupViewerVC)
    func didPressSettings(at popoverAnchor: PopoverAnchor, in viewController: GroupViewerVC)
    func didPressPasswordAudit(in viewController: GroupViewerVC)
    func didPressFaviconsDownload(in viewController: GroupViewerVC)
    func didPressPasswordGenerator(at popoverAnchor: PopoverAnchor, in viewController: GroupViewerVC)
    func didPressEncryptionSettings(in viewController: GroupViewerVC)

    func didSelectGroup(_ group: Group?, in viewController: GroupViewerVC) -> Bool

    func didSelectEntry(_ entry: Entry?, in viewController: GroupViewerVC) -> Bool

    func didPressCreateGroup(
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )
    func didPressCreateEntry(
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )

    func didPressEditGroup(
        _ group: Group,
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )
    func didPressEditEntry(
        _ entry: Entry,
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )

    func didPressDeleteGroup(
        _ group: Group,
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )

    func didPressDeleteEntry(
        _ entry: Entry,
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )

    func didPressRelocateItem(
        _ item: DatabaseItem,
        mode: ItemRelocationMode,
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )

    func didPressEmptyRecycleBinGroup(
        _ recycleBinGroup: Group,
        at popoverAnchor: PopoverAnchor,
        in viewController: GroupViewerVC
    )

    func getActionPermissions(for group: Group) -> DatabaseItem.ActionPermissions
    func getActionPermissions(for entry: Entry) -> DatabaseItem.ActionPermissions
}

final class GroupViewerVC:
    TableViewControllerWithContextActions,
    Refreshable
{
    private enum CellID {
        static let announcement = "AnnouncementCell"
        static let emptyGroup = "EmptyGroupCell"
        static let group = "GroupCell"
        static let entry = "EntryCell"
        static let nothingFound = "NothingFoundCell"
    }

    weak var delegate: GroupViewerDelegate?

    @IBOutlet private weak var sortOrderButton: UIBarButtonItem!
    @IBOutlet private weak var databaseMenuButton: UIBarButtonItem!
    @IBOutlet private weak var reloadDatabaseButton: UIBarButtonItem!
    @IBOutlet private weak var passwordGeneratorButton: UIBarButtonItem!

    weak var group: Group? {
        didSet {
            refresh()
        }
    }

    var isGroupEmpty: Bool {
        return groupsSorted.isEmpty && entriesSorted.isEmpty
    }

    var canDownloadFavicons: Bool = true
    var canChangeEncryptionSettings: Bool = true

    private var titleView = DatabaseItemTitleView()

    private var groupsSorted = [Weak<Group>]()
    private var entriesSorted = [Weak<Entry>]()

    private var createItemButton: UIBarButtonItem!

    private var actionPermissions = DatabaseItem.ActionPermissions()

    internal var announcements = [AnnouncementItem]() {
        didSet {
            guard isViewLoaded else { return }
            tableView.reloadSections([0], with: .automatic)
        }
    }

    private var isActivateSearch: Bool = false
    private var searchHelper = SearchHelper()
    private var searchResults = [GroupedItems]()
    private var searchController: UISearchController!
    var isSearchActive: Bool {
        guard let searchController = searchController else { return false }
        return searchController.isActive && (searchController.searchBar.text?.isNotEmpty ?? false)
    }

    override var canDismissFromKeyboard: Bool {
        return !(searchController?.isActive ?? false)
    }

    private var cellRefreshTimer: Timer?
    private var settingsNotifications: SettingsNotifications!


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.register(AnnouncementCell.classForCoder(), forCellReuseIdentifier: CellID.announcement)
        tableView.selectionFollowsFocus = true

        createItemButton = UIBarButtonItem(
            title: LString.actionCreate,
            image: .symbol(.plus),
            primaryAction: nil,
            menu: nil)
        navigationItem.setRightBarButton(createItemButton, animated: false)
        navigationItem.titleView = titleView
        reloadDatabaseButton.title = LString.actionReloadDatabase
        passwordGeneratorButton.title = LString.PasswordGenerator.titleRandomGenerator

        settingsNotifications = SettingsNotifications(observer: self)

        let isRootGroup = group?.isRoot ?? false
        isActivateSearch = Settings.current.isStartWithSearch && isRootGroup
        setupSearch()
        if isRootGroup {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cellRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refreshDynamicCells()
        }
        refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        settingsNotifications.startObserving()

        navigationItem.hidesSearchBarWhenScrolling = true
        if isActivateSearch {
            isActivateSearch = false 
            DispatchQueue.main.async { [weak searchController] in
                searchController?.searchBar.becomeFirstResponder()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        settingsNotifications.stopObserving()
        cellRefreshTimer?.invalidate()
        cellRefreshTimer = nil
    }

    private func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController

        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.barStyle = .default
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.delegate = self

        definesPresentationContext = true
        searchController.searchResultsUpdater = self
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(
                action: #selector(activateSearch),
                input: "f",
                modifierFlags: [.command],
                discoverabilityTitle: LString.titleSearch
            )
        ]
    }

    @objc func activateSearch() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.searchController.isActive = true
            self.searchController.searchBar.becomeFirstResponderWhenSafe()
        }
    }

    func refresh() {
        guard isViewLoaded, let group = group else { return }

        titleView.titleLabel.setText(group.name, strikethrough: group.isExpired)
        titleView.iconView.image = UIImage.kpIcon(forGroup: group)
        navigationItem.title = titleView.titleLabel.text

        actionPermissions =
            delegate?.getActionPermissions(for: group) ??
            DatabaseItem.ActionPermissions()
        createItemButton.isEnabled =
            actionPermissions.canCreateGroup ||
            actionPermissions.canCreateEntry

        createItemButton.menu = makeCreateItemMenu(for: createItemButton)
        configureDatabaseMenuButton(databaseMenuButton)

        if isSearchActive {
            updateSearchResults(for: searchController)
        } else {
            sortGroupItems()
        }
        tableView.reloadData()

        sortOrderButton.menu = makeListSettingsMenu()
        sortOrderButton.image = .symbol(.listBullet)
    }

    private func refreshDynamicCells() {
        tableView.visibleCells.forEach {
            if let entryCell = $0 as? GroupViewerEntryCell {
                entryCell.refresh()
            }
        }
    }

    private func sortGroupItems() {
        groupsSorted.removeAll()
        entriesSorted.removeAll()
        guard let group = self.group else { return }

        let groupSortOrder = Settings.current.groupSortOrder
        let weakGroupsSorted = group.groups
            .sorted { groupSortOrder.compare($0, $1) }
            .map { Weak($0) }
        let weakEntriesSorted = group.entries
            .sorted { groupSortOrder.compare($0, $1) }
            .map { Weak($0) }

        groupsSorted.append(contentsOf: weakGroupsSorted)
        entriesSorted.append(contentsOf: weakEntriesSorted)
    }

    private func configureDatabaseMenuButton(_ barButton: UIBarButtonItem) {
        barButton.title = LString.titleDatabaseOperations
        let lockDatabaseAction = UIAction(
            title: LString.actionLockDatabase,
            image: .symbol(.lock),
            attributes: [.destructive],
            handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didPressLockDatabase(in: self)
            }
        )
        let printDatabaseAction = UIAction(
            title: LString.actionPrint,
            image: .symbol(.printer),
            handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didPressPrintDatabase(in: self)
            }
        )
        let changeMasterKeyAction = UIAction(
            title: LString.actionChangeMasterKey,
            image: .symbol(.key),
            handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didPressChangeMasterKey(in: self)
            }
        )
        let passwordAuditAction = UIAction(
            title: LString.titlePasswordAudit,
            image: .symbol(.networkBadgeShield),
            handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didPressPasswordAudit(in: self)
            }
        )
        let faviconsDownloadAction = UIAction(
            title: LString.actionDownloadFavicons,
            image: .symbol(.wandAndStars),
            handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didPressFaviconsDownload(in: self)
            }
        )

        let encryptionSettingsAction = UIAction(
            title: LString.titleEncryptionSettings,
            image: .symbol(.lockShield),
            handler: { [weak self] _ in
                guard let self else { return }
                self.delegate?.didPressEncryptionSettings(in: self)
            }
        )

        if !actionPermissions.canEditDatabase {
            changeMasterKeyAction.attributes.insert(.disabled)
            faviconsDownloadAction.attributes.insert(.disabled)
            encryptionSettingsAction.attributes.insert(.disabled)
        }

        let frequentMenu = UIMenu(
            options: [.displayInline],
            children: [
                passwordAuditAction,
                canDownloadFavicons ? faviconsDownloadAction : nil,
                printDatabaseAction,
            ].compactMap { $0 }
        )
        let rareMenu = UIMenu(
            options: [.displayInline],
            children: [
                changeMasterKeyAction,
                canChangeEncryptionSettings ? encryptionSettingsAction : nil,
            ].compactMap { $0 }
        )
        let lockMenu = UIMenu(options: [.displayInline], children: [lockDatabaseAction])

        var menuElements = [frequentMenu, rareMenu, lockMenu]
        if #available(iOS 16, *) {
            barButton.preferredMenuElementOrder = .fixed
        } else {
            menuElements.reverse()
        }
        let menu = UIMenu(children: menuElements)
        barButton.menu = menu
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchActive {
            return searchResults.isEmpty ? 1 : searchResults.count
        } else {
            return 1
        }
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        if isSearchActive {
            return searchResults.isEmpty ? nil : searchResults[section].group.name
        } else {
            return nil
        }
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if isSearchActive {
            if section < searchResults.count {
                return searchResults[section].scoredItems.count
            } else {
                return (section == 0 ? 1 : 0)
            }
        } else {
            if isGroupEmpty {
                return announcements.count + 1 // for "Nothing here" cell
            } else {
                return announcements.count + groupsSorted.count + entriesSorted.count
            }
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if isSearchActive {
            return makeSearchResultCell(at: indexPath)
        } else {
            if announcements.indices.contains(indexPath.row) {
                return makeAnnouncementCell(at: indexPath)
            } else {
                return makeDatabaseItemCell(at: indexPath)
            }
        }
    }

    private func makeAnnouncementCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: CellID.announcement, for: indexPath)
            as! AnnouncementCell
        let announcement = announcements[indexPath.row]
        cell.announcementView.apply(announcement)
        return cell
    }

    private func makeSearchResultCell(at indexPath: IndexPath) -> UITableViewCell {
        if isSearchActive && searchResults.isEmpty {
            return tableView.dequeueReusableCell(
                withIdentifier: CellID.nothingFound,
                for: indexPath)
        }

        let section = searchResults[indexPath.section]
        let foundItem = section.scoredItems[indexPath.row].item
        switch foundItem {
        case let entry as Entry:
            return getEntryCell(for: entry, at: indexPath)
        case let group as Group:
            return getGroupCell(for: group, at: indexPath)
        default:
            fatalError("Invalid usage")
        }
    }

    private func makeDatabaseItemCell(at indexPath: IndexPath) -> UITableViewCell {
        if isGroupEmpty {
            return tableView.dequeueReusableCell(withIdentifier: CellID.emptyGroup, for: indexPath)
        }

        if let group = getGroup(at: indexPath) {
            return getGroupCell(for: group, at: indexPath)
        } else if let entry = getEntry(at: indexPath) {
            return getEntryCell(for: entry, at: indexPath)
        } else {
            assertionFailure()
            return tableView.dequeueReusableCell(withIdentifier: CellID.group, for: indexPath)
        }
    }

    private func getGroupCell(for group: Group, at indexPath: IndexPath) -> GroupViewerGroupCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellID.group,
            for: indexPath)
            as! GroupViewerGroupCell

        let itemCount = group.groups.count + group.entries.count
        cell.titleLabel.setText(group.name, strikethrough: group.isExpired)
        cell.subtitleLabel?.setText("\(itemCount)", strikethrough: group.isExpired)
        cell.iconView?.image = UIImage.kpIcon(forGroup: group)
        cell.accessibilityLabel = String.localizedStringWithFormat(
            LString.titleGroupDescriptionTemplate,
            group.name)
        return cell
    }

    private func getEntryCell(for entry: Entry, at indexPath: IndexPath) -> GroupViewerEntryCell {
        let entryCell = tableView.dequeueReusableCell(
            withIdentifier: CellID.entry,
            for: indexPath)
            as! GroupViewerEntryCell

        setupEntryCell(entryCell, entry: entry)
        return entryCell
    }

    private func setupEntryCell(_ cell: GroupViewerEntryCell, entry: Entry) {
        cell.titleLabel.setText(entry.resolvedTitle, strikethrough: entry.isExpired)
        cell.subtitleLabel?.setText(getDetailInfo(for: entry), strikethrough: entry.isExpired)
        cell.iconView?.image = UIImage.kpIcon(forEntry: entry)

        cell.totpGenerator = TOTPGeneratorFactory.makeGenerator(for: entry)
        cell.otpCopiedHandler = { [weak self] in
            self?.showNotification(LString.otpCodeCopiedToClipboard)
        }

        cell.hasAttachments = entry.attachments.count > 0
        cell.accessibilityCustomActions = getAccessibilityActions(for: entry)
    }

    private func getDetailInfo(for entry: Entry) -> String? {
        switch Settings.current.entryListDetail {
        case .none:
            return nil
        case .userName:
            return entry.getField(EntryField.userName)?.premiumDecoratedValue
        case .password:
            return entry.getField(EntryField.password)?.premiumDecoratedValue
        case .url:
            return entry.getField(EntryField.url)?.premiumDecoratedValue
        case .notes:
            return entry.getField(EntryField.notes)?
                .premiumDecoratedValue
                .replacingOccurrences(of: "\r", with: " ")
                .replacingOccurrences(of: "\n", with: " ")
        case .lastModifiedDate:
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: entry.lastModificationTime)
        case .tags:
            guard let entry2 = entry as? Entry2 else {
                return nil
            }
            return entry2.resolvingTags().joined(separator: ", ")
        }
    }


    @available(iOS 13, *)
    private func getAccessibilityActions(for entry: Entry) -> [UIAccessibilityCustomAction] {
        var actions = [UIAccessibilityCustomAction]()

        let nonTitleFields = entry.fields.filter { $0.name != EntryField.title }
        nonTitleFields.reversed().forEach { field in
            let actionName = String.localizedStringWithFormat(
                LString.actionCopyToClipboardTemplate,
                field.name)
            let action = UIAccessibilityCustomAction(name: actionName) { [weak field] _ -> Bool in
                if let fieldValue = field?.resolvedValue {
                    Clipboard.general.insert(fieldValue)
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: LString.titleCopiedToClipboard
                    )
                }
                return true
            }
            actions.append(action)
        }
        return actions
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearchActive {
            didSelectItem(at: indexPath)
        } else {
            if !isGroupEmpty {
                didSelectItem(at: indexPath)
            }
        }
    }


    private func getIndexPath(for group: Group) -> IndexPath? {
        guard let groupIndex = groupsSorted.firstIndex(where: { $0.value === group }) else {
            return nil
        }
        let indexPath = IndexPath(row: announcements.count + groupIndex, section: 0)
        return indexPath
    }

    private func getIndexPath(for entry: Entry) -> IndexPath? {
        guard let entryIndex = entriesSorted.firstIndex(where: { $0.value === entry }) else {
            return nil
        }
        let rowNumber = announcements.count + groupsSorted.count + entryIndex
        let indexPath = IndexPath(row: rowNumber, section: 0)
        return indexPath
    }

    func selectEntry(_ entry: Entry?, animated: Bool) {
        guard let entry = entry else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: animated)
            }
            return
        }
        guard let indexPath = getIndexPath(for: entry) else {
            return
        }
        tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
        tableView.scrollToRow(at: indexPath, at: .none, animated: animated)
    }

    func getGroup(at indexPath: IndexPath) -> Group? {
        if isSearchActive {
            return getSearchResult(at: indexPath) as? Group
        } else {
            let groupIndex = indexPath.row - announcements.count
            guard groupsSorted.indices.contains(groupIndex) else { return nil }
            return groupsSorted[groupIndex].value
        }
    }

    func getEntry(at indexPath: IndexPath) -> Entry? {
        if isSearchActive {
            return getSearchResult(at: indexPath) as? Entry
        } else {
            let entryIndex = indexPath.row - announcements.count - groupsSorted.count
            guard entriesSorted.indices.contains(entryIndex) else { return nil }
            return entriesSorted[entryIndex].value
        }
    }

    private func getSearchResult(at indexPath: IndexPath) -> DatabaseItem? {
        guard indexPath.section < searchResults.count else { return  nil }
        let searchResult = searchResults[indexPath.section]
        guard indexPath.row < searchResult.scoredItems.count else { return nil }
        return searchResult.scoredItems[indexPath.row].item
    }

    func getItem(at indexPath: IndexPath) -> DatabaseItem? {
        if let entry = getEntry(at: indexPath) {
            return entry
        }
        if let group = getGroup(at: indexPath) {
            return group
        }
        return nil
    }

    func didSelectItem(at indexPath: IndexPath) {
        var shouldKeepSelection = true
        if let selectedGroup = getGroup(at: indexPath) {
            shouldKeepSelection = delegate?.didSelectGroup(selectedGroup, in: self) ?? true
        } else if let selectedEntry = getEntry(at: indexPath) {
            shouldKeepSelection = delegate?.didSelectEntry(selectedEntry, in: self) ?? true
        }

        if !shouldKeepSelection {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }


    private func makeListSettingsMenu() -> UIMenu {
        let currentDetail = Settings.current.entryListDetail
        let entrySubtitleActions = Settings.EntryListDetail.allCases.map { entryListDetail in
            UIAction(
                title: entryListDetail.longTitle,
                state: (currentDetail == entryListDetail) ? .on : .off,
                handler: { [weak self] _ in
                    Settings.current.entryListDetail = entryListDetail
                    self?.refresh()
                }
            )
        }
        let entrySubtitleMenu = UIMenu.make(
            title: LString.titleEntrySubtitle,
            reverse: true,
            options: [],
            children: entrySubtitleActions
        )

        let sortOrderMenuItems = UIMenu.makeDatabaseItemSortMenuItems(
            current: Settings.current.groupSortOrder,
            handler: { [weak self] newSortOrder in
                Settings.current.groupSortOrder = newSortOrder
                self?.refresh()
            }
        )
        let sortOrderMenu = UIMenu.make(
            title: LString.titleSortBy,
            reverse: true,
            options: [],
            macOptions: [],
            children: sortOrderMenuItems
        )
        return UIMenu.make(
            title: "",
            reverse: true,
            options: [],
            children: [sortOrderMenu, entrySubtitleMenu]
        )
    }

    override func getContextActionsForRow(
        at indexPath: IndexPath,
        forSwipe: Bool
    ) -> [ContextualAction] {
        var isNonEmptyRecycleBinGroup = false
        let permissions: DatabaseItem.ActionPermissions
        if let group = getGroup(at: indexPath) {
            permissions = delegate?.getActionPermissions(for: group) ?? DatabaseItem.ActionPermissions()
            let isRecycleBin = (group === group.database?.getBackupGroup(createIfMissing: false))
            isNonEmptyRecycleBinGroup = isRecycleBin && (!group.entries.isEmpty || !group.groups.isEmpty)
        } else if let entry = getEntry(at: indexPath) {
            permissions = delegate?.getActionPermissions(for: entry) ?? DatabaseItem.ActionPermissions()
        } else {
            return []
        }

        let editAction = ContextualAction(
            title: LString.actionEdit,
            imageName: .squareAndPencil,
            style: .default,
            color: UIColor.actionTint,
            handler: { [weak self, indexPath] in
                self?.didPressEditItem(at: indexPath)
            }
        )
        let deleteAction = ContextualAction(
            title: LString.actionDelete,
            imageName: .trash,
            style: .destructive,
            color: UIColor.destructiveTint,
            handler: { [weak self, indexPath] in
                self?.didPressDeleteItem(at: indexPath)
            }
        )
        let emptyRecycleBinAction = ContextualAction(
            title: LString.actionEmptyRecycleBinGroup,
            imageName: .trash,
            style: .destructive,
            color: UIColor.destructiveTint,
            handler: { [weak self, indexPath] in
                self?.didPressEmptyRecycleBinGroup(at: indexPath)
            }
        )

        var actions = [ContextualAction]()

        if forSwipe {
            if permissions.canDeleteItem {
                actions.append(deleteAction)
            }
            if permissions.canEditItem {
                actions.append(editAction)
            }
            return actions
        }

        if permissions.canEditItem {
            actions.append(editAction)
        }
        if permissions.canMoveItem {
            let moveAction = ContextualAction(
                title: LString.actionMove,
                imageName: .folder,
                style: .default,
                handler: { [weak self, indexPath] in
                    self?.didPressRelocateItem(at: indexPath, mode: .move)
                }
            )
            let copyAction = ContextualAction(
                title: LString.actionCopy,
                imageName: .docOnDoc,
                style: .default,
                handler: { [weak self, indexPath] in
                    self?.didPressRelocateItem(at: indexPath, mode: .copy)
                }
            )
            actions.append(moveAction)
            actions.append(copyAction)
        }
        if permissions.canDeleteItem {
            actions.append(deleteAction)
            if isNonEmptyRecycleBinGroup {
                actions.append(emptyRecycleBinAction)
            }
        }
        return actions
    }


    private func makeCreateItemMenu(for button: UIBarButtonItem) -> UIMenu {
        let popoverAnchor = PopoverAnchor(barButtonItem: button)

        let createGroupAction = UIAction(
            title: LString.actionCreateGroup,
            image: nil,
            attributes: actionPermissions.canCreateGroup ? [] : [.disabled],
            handler: { [weak self, popoverAnchor] _ in
                guard let self = self else { return }
                self.delegate?.didPressCreateGroup(at: popoverAnchor, in: self)
            }
        )

        let createEntryAction = UIAction(
            title: LString.actionCreateEntry,
            image: nil,
            attributes: actionPermissions.canCreateEntry ? [] : [.disabled],
            handler: { [weak self, popoverAnchor] _ in
                guard let self = self else { return }
                self.delegate?.didPressCreateEntry(at: popoverAnchor, in: self)
            }
        )

        return UIMenu.make(
            title: "",
            reverse: false,
            options: [],
            children: [createGroupAction, createEntryAction]
        )
    }

    func didPressEditItem(at indexPath: IndexPath) {
        let popoverAnchor = PopoverAnchor(tableView: tableView, at: indexPath)
        if let targetGroup = getGroup(at: indexPath) {
            delegate?.didPressEditGroup(targetGroup, at: popoverAnchor, in: self)
        } else if let targetEntry = getEntry(at: indexPath) {
            delegate?.didPressEditEntry(targetEntry, at: popoverAnchor, in: self)
        } else {
            assertionFailure("Unknown database item type")
        }
    }

    func didPressDeleteItem(at indexPath: IndexPath) {
        let popoverAnchor = PopoverAnchor(tableView: tableView, at: indexPath)

        let confirmationAlert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        if let targetGroup = getGroup(at: indexPath) {
            confirmationAlert.title = targetGroup.name
            confirmationAlert.addAction(title: LString.actionDelete, style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didPressDeleteGroup(targetGroup, at: popoverAnchor, in: self)
            }
        } else if let targetEntry = getEntry(at: indexPath) {
            confirmationAlert.title = targetEntry.resolvedTitle
            confirmationAlert.addAction(title: LString.actionDelete, style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didPressDeleteEntry(targetEntry, at: popoverAnchor, in: self)
            }
        } else {
            assertionFailure("Unknown database item type")
        }

        confirmationAlert.addAction(title: LString.actionCancel, style: .cancel, handler: nil)
        confirmationAlert.modalPresentationStyle = .popover
        popoverAnchor.apply(to: confirmationAlert.popoverPresentationController)
        present(confirmationAlert, animated: true, completion: nil)
    }

    private func didPressEmptyRecycleBinGroup(at indexPath: IndexPath) {
        let popoverAnchor = PopoverAnchor(tableView: tableView, at: indexPath)
        guard let targetGroup = getGroup(at: indexPath) else {
            assertionFailure("Cannot find a group at specified index path")
            return
        }
        let confirmationAlert = UIAlertController.make(
            title: LString.confirmEmptyRecycleBinGroup,
            message: nil,
            dismissButtonTitle: LString.actionCancel)
        confirmationAlert.addAction(title: LString.actionEmptyRecycleBinGroup, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didPressEmptyRecycleBinGroup(targetGroup, at: popoverAnchor, in: self)
        }
        confirmationAlert.modalPresentationStyle = .popover
        popoverAnchor.apply(to: confirmationAlert.popoverPresentationController)
        present(confirmationAlert, animated: true, completion: nil)
    }

    func didPressRelocateItem(at indexPath: IndexPath, mode: ItemRelocationMode) {
        guard let selectedItem = getItem(at: indexPath) else {
            Diag.warning("No items selected for relocation")
            assertionFailure()
            return
        }

        let popoverAnchor = PopoverAnchor(tableView: tableView, at: indexPath)
        delegate?.didPressRelocateItem(selectedItem, mode: mode, at: popoverAnchor, in: self)
    }

    @IBAction private func didPressReloadDatabase(_ sender: UIBarButtonItem) {
        let popoverAnchor = PopoverAnchor(barButtonItem: sender)
        delegate?.didPressReloadDatabase(at: popoverAnchor, in: self)
    }

    @IBAction private func didPressSettings(_ sender: UIBarButtonItem) {
        let popoverAnchor = PopoverAnchor(barButtonItem: sender)
        delegate?.didPressSettings(at: popoverAnchor, in: self)
    }

    @IBAction private func didPressPasswordGenerator(_ sender: UIBarButtonItem) {
        let popoverAnchor = PopoverAnchor(barButtonItem: sender)
        delegate?.didPressPasswordGenerator(at: popoverAnchor, in: self)
    }
}

#if targetEnvironment(macCatalyst)
extension GroupViewerVC {
    override func tableView(
        _ tableView: UITableView,
        selectionFollowsFocusForRowAt indexPath: IndexPath
    ) -> Bool {
        let isEntry = getEntry(at: indexPath) != nil
        return isEntry
    }
}
#endif

extension GroupViewerVC: SettingsObserver {
    func settingsDidChange(key: Settings.Keys) {
        switch key {
        case .appLockEnabled, .rememberDatabaseKey:
            refresh()
        default:
            break
        }
    }
}


extension GroupViewerVC: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        guard let database = group?.database else { return }
        searchResults = searchHelper.findEntriesAndGroups(database: database, searchText: searchText)
        searchResults.sort(order: Settings.current.groupSortOrder)
        tableView.reloadData()
    }
}

extension GroupViewerVC: UISearchControllerDelegate {
    public func didDismissSearchController(_ searchController: UISearchController) {
        refresh()
    }
}
