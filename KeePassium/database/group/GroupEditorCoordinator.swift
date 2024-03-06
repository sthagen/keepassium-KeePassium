//  KeePassium Password Manager
//  Copyright © 2018–2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol GroupEditorCoordinatorDelegate: AnyObject {
    func didUpdateGroup(_ group: Group, in coordinator: GroupEditorCoordinator)

    func didRelocateDatabase(_ databaseFile: DatabaseFile, to url: URL)
}

final class GroupEditorCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var dismissHandler: CoordinatorDismissHandler?
    weak var delegate: GroupEditorCoordinatorDelegate?

    private let router: NavigationRouter
    private let databaseFile: DatabaseFile
    private let database: Database
    private let parent: Group 
    private let originalGroup: Group? 

    private let groupEditorVC: GroupEditorVC

    private var group: Group

    var databaseSaver: DatabaseSaver?
    var fileExportHelper: FileExportHelper?
    var savingProgressHost: ProgressViewHost? { return router }
    var saveSuccessHandler: (() -> Void)?

    init(router: NavigationRouter, databaseFile: DatabaseFile, parent: Group, target: Group?) {
        self.router = router
        self.databaseFile = databaseFile
        self.database = databaseFile.database
        self.parent = parent
        self.originalGroup = target

        if let _target = target {
            group = _target.clone(makeNewUUID: false)
        } else {
            group = parent.createGroup(detached: true)
            group.name = LString.defaultNewGroupName
        }
        group.touch(.accessed)

        let groupProperties = GroupEditorVC.Property.makeAll(for: group, parent: parent)
        groupEditorVC = GroupEditorVC(
            group: group,
            parent: parent,
            properties: groupProperties,
            showTags: database is Database2
        )
        groupEditorVC.delegate = self
        if originalGroup == nil {
            groupEditorVC.title = LString.titleCreateGroup
        } else {
            groupEditorVC.title = LString.titleEditGroup
        }
    }

    deinit {
        assert(childCoordinators.isEmpty)
        removeAllChildCoordinators()
    }

    func start() {
        router.push(groupEditorVC, animated: true, onPop: { [weak self] in
            guard let self = self else { return }
            self.removeAllChildCoordinators()
            self.dismissHandler?(self)
        })
        refresh()
    }

    private func refresh() {
        groupEditorVC.refresh()
    }

    private func abortAndDismiss() {
        router.pop(animated: true)
    }

    private func saveChangesAndDismiss() {
        group.touch(.modified, updateParents: false)
        if let originalGroup = originalGroup {
            group.apply(to: originalGroup, makeNewUUID: false)
            delegate?.didUpdateGroup(originalGroup, in: self)
        } else {
            parent.add(group: group)
            delegate?.didUpdateGroup(group, in: self)
        }

        saveDatabase(databaseFile)
    }

    private func showDiagnostics() {
        let diagnosticsViewerCoordinator = DiagnosticsViewerCoordinator(router: router)
        diagnosticsViewerCoordinator.dismissHandler = { [weak self] coordinator in
            self?.removeChildCoordinator(coordinator)
        }
        addChildCoordinator(diagnosticsViewerCoordinator)
        diagnosticsViewerCoordinator.start()
    }

    func showIconPicker() {
        let iconPickerCoordinator = ItemIconPickerCoordinator(
            router: router,
            databaseFile: databaseFile,
            customFaviconUrl: nil
        )
        iconPickerCoordinator.item = group
        iconPickerCoordinator.dismissHandler = { [weak self] coordinator in
            self?.removeChildCoordinator(coordinator)
        }
        iconPickerCoordinator.delegate = self
        addChildCoordinator(iconPickerCoordinator)
        iconPickerCoordinator.start()
    }

    func showPasswordGenerator(
        for textInput: TextInputView,
        in groupEditor: GroupEditorVC
    ) {
        let passGenCoordinator = PasswordGeneratorCoordinator(router: router, quickMode: true)
        passGenCoordinator.dismissHandler = { [weak self] coordinator in
            self?.removeChildCoordinator(coordinator)
        }
        passGenCoordinator.delegate = self
        passGenCoordinator.context = textInput
        passGenCoordinator.start()
        addChildCoordinator(passGenCoordinator)
    }
}

extension GroupEditorCoordinator: GroupEditorDelegate {
    func didPressCancel(in groupEditor: GroupEditorVC) {
        abortAndDismiss()
    }

    func didPressDone(in groupEditor: GroupEditorVC) {
        groupEditor.resignFirstResponder()
        requestFormatUpgradeIfNecessary(
            in: groupEditor,
            for: database,
            and: .groupTags) { [weak self] in
                self?.saveChangesAndDismiss()
            }
    }

    func didPressChangeIcon(at popoverAnchor: PopoverAnchor, in groupEditor: GroupEditorVC) {
        showIconPicker()
    }

    func didPressRandomizer(for textInput: TextInputView, in groupEditor: GroupEditorVC) {
        showPasswordGenerator(for: textInput, in: groupEditor)
    }

    func didPressTags(in groupEditor: GroupEditorVC) {
        let tagsCoordinator = TagSelectorCoordinator(
            item: group,
            parent: originalGroup?.parent,
            database: database,
            router: router
        )
        tagsCoordinator.dismissHandler = { [weak self, tagsCoordinator] coordinator in
            self?.group.tags = tagsCoordinator.selectedTags
            self?.refresh()
            self?.removeChildCoordinator(coordinator)
        }
        tagsCoordinator.start()
        addChildCoordinator(tagsCoordinator)
    }
}

extension GroupEditorCoordinator: PasswordGeneratorCoordinatorDelegate {
    func didAcceptPassword(_ password: String, in coordinator: PasswordGeneratorCoordinator) {
        guard let context = coordinator.context,
              let textInput = context as? TextInputView
        else {
            assertionFailure()
            return
        }
        textInput.replace(textInput.selectedOrFullTextRange, withText: password)
        refresh()
    }
}

extension GroupEditorCoordinator: ItemIconPickerCoordinatorDelegate {
    func didRelocateDatabase(_ databaseFile: DatabaseFile, to url: URL) {
        delegate?.didRelocateDatabase(databaseFile, to: url)
    }

    func didSelectIcon(standardIcon: IconID, in coordinator: ItemIconPickerCoordinator) {
        group.iconID = standardIcon
        if let group2 = group as? Group2 {
            group2.customIconUUID = .ZERO
        }
        refresh()
    }

    func didSelectIcon(customIcon: UUID, in coordinator: ItemIconPickerCoordinator) {
        guard let group2 = group as? Group2 else { return }
        group2.customIconUUID = customIcon
        refresh()
    }

    func didDeleteIcon(customIcon: UUID, in coordinator: ItemIconPickerCoordinator) {
        if let group2 = group as? Group2,
           group2.customIconUUID == customIcon
        {
            delegate?.didUpdateGroup(group, in: self)
            refresh()
        }
    }
}

extension GroupEditorCoordinator: DatabaseSaving {
    func didCancelSaving(databaseFile: DatabaseFile) {
    }

    func didSave(databaseFile: DatabaseFile) {
        router.pop(animated: true)
    }

    func getDatabaseSavingErrorParent() -> UIViewController {
        return groupEditorVC
    }

    func getDiagnosticsHandler() -> (() -> Void)? {
        return showDiagnostics
    }

    func didRelocate(databaseFile: DatabaseFile, to newURL: URL) {
        delegate?.didRelocateDatabase(databaseFile, to: newURL)
    }
}
