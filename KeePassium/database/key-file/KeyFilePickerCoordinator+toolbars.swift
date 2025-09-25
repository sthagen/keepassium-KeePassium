//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension KeyFilePickerCoordinator {
    class ToolbarDecorator: FilePickerToolbarDecorator {
        weak var coordinator: KeyFilePickerCoordinator?

        func getLeftBarButtonItems(mode: FilePickerToolbarMode) -> [UIBarButtonItem]? {
            return nil
        }

        func getRightBarButtonItems(mode: FilePickerToolbarMode) -> [UIBarButtonItem]? {
            guard let coordinator else { assertionFailure(); return nil }
            switch mode {
            case let .normal(hasSelectableFiles):
                var barItems = [UIBarButtonItem]()
                let selectItemsAction = UIBarButtonItem(
                    title: LString.actionSelect,
                    primaryAction: UIAction { [weak coordinator] _ in
                        coordinator?._startSelecting()
                    }
                )
                selectItemsAction.isEnabled = hasSelectableFiles
                let addKeyFileBarButton = UIBarButtonItem(
                    title: LString.actionAddKeyFile,
                    image: .symbol(.plus),
                    primaryAction: nil,
                    menu: coordinator._makeAddKeyFileMenu()
                )

                barItems.append(addKeyFileBarButton)
                barItems.append(selectItemsAction)
                return barItems
            case .bulkEdit:
                let doneBulkEditingButton = UIBarButtonItem(systemItem: .done, primaryAction: UIAction {
                    [weak coordinator] _ in
                    coordinator?._didPressDoneBulkEditing()
                })
                return [doneBulkEditingButton]
            }
        }

        func getToolbarItems(mode: FilePickerToolbarMode) -> [UIBarButtonItem]? {
            switch mode {
            case .normal:
                if ProcessInfo.isRunningOnMac {
                    let refreshAction = UIBarButtonItem(
                        systemItem: .refresh,
                        primaryAction: UIAction { [weak coordinator] action in
                            coordinator?.refresh()
                        }
                    )
                    return [
                        .flexibleSpace(),
                        refreshAction,
                        .flexibleSpace(),
                    ]
                } else {
                    return nil
                }
            case .bulkEdit(let selectedFiles):
                let bulkDeleteButton = UIBarButtonItem(
                    systemItem: .trash,
                    primaryAction: UIAction { [weak coordinator] action in
                        coordinator?._confirmAndBulkDeleteFiles(
                            selectedFiles,
                            at: action.presentationSourceItem?.asPopoverAnchor
                        )
                    }
                )
                bulkDeleteButton.title = LString.actionDelete
                bulkDeleteButton.isEnabled = selectedFiles.count > 0
                return [.flexibleSpace(), bulkDeleteButton]
            }
        }
    }

    internal func _makeAddKeyFileMenu() -> UIMenu {
        let createKeyFileAction = UIAction(
            title: LString.actionCreateKeyFile,
            image: .symbol(.plus),
            handler: { [weak self] action in
                let popoverAnchor = action.presentationSourceItem?.asPopoverAnchor
                self?.didPressCreateKeyFile(at: popoverAnchor)
            }
        )
        let importKeyFileAction = UIAction(
            title: LString.actionImportKeyFile,
            subtitle: LString.importKeyFileDescription,
            image: .symbol(.folderBadgePlus),
            handler: { [weak self] action in
                let popoverAnchor = action.presentationSourceItem?.asPopoverAnchor
                self?.didPressImportKeyFile(at: popoverAnchor)
            }
        )
        let useKeyFileAction = UIAction(
            title: LString.actionUseKeyFile,
            subtitle: LString.useKeyFileDescription,
            image: .symbol(.folder),
            handler: { [weak self] action in
                let popoverAnchor = action.presentationSourceItem?.asPopoverAnchor
                self?.didPressUseKeyFile(at: popoverAnchor)
            }
        )
        let connectToServerAction = UIAction(
            title: LString.actionConnectToServer,
            image: .symbol(.network),
            handler: { [weak self] action in
                let popoverAnchor = action.presentationSourceItem?.asPopoverAnchor
                self?.didPressConnectToServer(at: popoverAnchor)
            }
        )
        return UIMenu(children: [
            importKeyFileAction,
            useKeyFileAction,
            UIMenu(inlineChildren: [connectToServerAction]),
            UIMenu(inlineChildren: [createKeyFileAction])
        ])
    }
}

extension KeyFilePickerCoordinator {
    private func didPressCancel() {
        dismiss()
    }

    private func didPressImportKeyFile(at popoverAnchor: PopoverAnchor?) {
        startAddingKeyFile(mode: .import, presenter: _filePickerVC)
    }

    private func didPressUseKeyFile(at popoverAnchor: PopoverAnchor?) {
        startAddingKeyFile(mode: .use, presenter: _filePickerVC)
    }

    private func didPressCreateKeyFile(at popoverAnchor: PopoverAnchor?) {
        startCreatingKeyFile(presenter: _filePickerVC)
    }

    private func didPressConnectToServer(at popoverAnchor: PopoverAnchor?) {
        startRemoteKeyFilePicker(presenter: _filePickerVC)
    }
}
