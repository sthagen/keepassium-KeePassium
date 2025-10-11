//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryCreatorCoordinator {
    final class ItemDecorator: EntryCreatorItemDecorator {
        weak var coordinator: EntryCreatorCoordinator?

        func getActionMenu(for fieldName: String) -> UIMenu? {
            switch fieldName {
            case EntryField.userName:
                return makeUsernameGeneratorMenu()
            case EntryField.password:
                return makePasswordGeneratorMenu()
            default:
                return nil
            }
        }

        func getGroupPickerMenu() -> UIMenu? {
            guard let coordinator,
                  let rootGroup = coordinator._databaseFile.database.root
            else { assertionFailure(); return nil }

            let selectedUUID = coordinator._entryData.parentGroup.runtimeUUID
            return makeGroupPickerMenu(for: rootGroup, selectedUUID: selectedUUID) as? UIMenu
        }
    }
}

fileprivate extension EntryCreatorCoordinator.ItemDecorator {

    func makeGroupPickerMenu(for group: Group, selectedUUID: UUID) -> UIMenuElement {
        let isRoot = (group.parent == nil)
        let thisGroupAction: UIAction
        if group.groups.isEmpty {
            thisGroupAction = makeGroupPickerAction(for: group, selected: group.runtimeUUID == selectedUUID)
            return thisGroupAction
        } else {
            let selectActionTitle = String.localizedStringWithFormat(
                LString.actionSelectNamedItemTemplate,
                group.name
            )
            thisGroupAction = makeGroupPickerAction(
                for: group,
                title: isRoot ? nil : selectActionTitle,
                selected: group.runtimeUUID == selectedUUID
            )
        }

        let subgroupElements = group.groups.map { group -> UIMenuElement in
            makeGroupPickerMenu(for: group, selectedUUID: selectedUUID)
        }
        return UIMenu(
            title: isRoot ? "" : group.name,
            image: isRoot ? nil : .kpIcon(forGroup: group),
            children: [
                thisGroupAction,
                UIMenu(inlineChildren: subgroupElements)
            ])
    }

    func makeGroupPickerAction(for group: Group, title: String? = nil, selected: Bool = false) -> UIAction {
        UIAction(
            title: title ?? group.name,
            image: .kpIcon(forGroup: group),
            state: selected ? .on : .off,
            handler: { [weak self] _ in
                self?.coordinator?._didSelectLocation(group)
            }
        )
    }

    func makeUsernameGeneratorMenu() -> UIMenu? {
        guard let coordinator else { return nil }
        let database = coordinator._databaseFile.database

        let applyUserName: UIActionHandler = { [weak coordinator] action in
            coordinator?._didSelectUsername(action.title)
        }
        let frequentUserNames = UserNameHelper.getUserNameSuggestions(from: database, count: 4)
        let frequentMenu = UIMenu(inlineChildren: frequentUserNames.map {
            UIAction(title: $0, image: nil, handler: applyUserName)
        })
        let randomUserNames = UserNameHelper.getRandomUserNames(count: 3)
        let randomMenu = UIMenu(
            title: LString.titleRandomUsernames,
            inlineChildren: randomUserNames.map {
                UIAction(title: $0, image: .symbol(.dieFace3), handler: applyUserName)
            })
        return UIMenu(
            title: LString.actionSelectUsername,
            image: .symbol(.person),
            children: [frequentMenu, randomMenu]
        )
    }

    func makePasswordGeneratorMenu() -> UIMenu? {
        let passwordGenerator = PasswordGenerator()
        let passphraseGenerator = PassphraseGenerator()
        let config = Settings.current.passwordGeneratorConfig

        var passwordActions = [UIAction]()
        passwordActions.append(makeRandomizerAction(
            mode: .basic,
            generator: passwordGenerator,
            reqs: config.basicModeConfig.toRequirements()))
        passwordActions.append(makeRandomizerAction(
            mode: .custom,
            generator: passwordGenerator,
            reqs: config.customModeConfig.toRequirements()))
        passwordActions.append(makeRandomizerAction(
            mode: .passphrase,
            generator: passphraseGenerator,
            reqs: config.passphraseModeConfig.toRequirements()))

        let showPassGenAction = UIAction(
            title: LString.PasswordGenerator.titleRandomGenerator,
            image: .symbol(.gearshape2),
            handler: { [weak coordinator] action in
                coordinator?._showPasswordGenerator()
            }
        )
        return UIMenu(
            title: LString.PasswordGenerator.titleRandomGenerator,
            image: .symbol(.dieFace3),
            children: [
                UIMenu(inlineChildren: passwordActions),
                showPassGenAction
            ]
        )
    }

    func makeRandomizerAction(
        mode: PasswordGeneratorMode,
        generator: PasswordGenerator,
        reqs: PasswordGeneratorRequirements,
    ) -> UIAction {
        var randomText: String
        do {
            randomText = try generator.generate(with: reqs)
        } catch {
            Diag.error("Unable to generate password: \(error)")
            randomText = "?"
        }
        let action = UIAction(title: randomText, image: .symbol(.dieFace3), handler: { [weak self] _ in
            self?.didSelectPassword(randomText, mode: mode)
        })
        return action
    }

    func didSelectPassword(_ password: String, mode: PasswordGeneratorMode) {
        let passGenConfig = Settings.current.passwordGeneratorConfig
        passGenConfig.lastMode = mode
        Settings.current.passwordGeneratorConfig = passGenConfig

        coordinator?._didSetPassword(password)
    }
}

extension EntryCreatorCoordinator: PasswordGeneratorCoordinatorDelegate {
    func _showPasswordGenerator() {
        let passGenCoordinator = PasswordGeneratorCoordinator(
            router: _router,
            quickMode: false,
            hasTarget: true
        )
        passGenCoordinator.delegate = self
        passGenCoordinator.start()
        addChildCoordinator(passGenCoordinator, onDismiss: nil)
    }

    func didAcceptPassword(_ password: String, in coordinator: PasswordGeneratorCoordinator) {
        _didSetPassword(password)
    }
}
