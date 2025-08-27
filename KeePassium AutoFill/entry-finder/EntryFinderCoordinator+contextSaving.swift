//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension EntryFinderCoordinator {

    internal var _canAddExtraURLs: Bool {
        let compatibleFormat = _databaseFile.database is Database2
        let readOnly = _databaseFile.status.contains(.readOnly)
        return compatibleFormat && !readOnly
    }

    internal func _withContextURL(
        of searchContext: AutoFillSearchContext,
        presenter: UIViewController,
        completion: @escaping (_ contextURL: URL?) -> Void
    ) {
        guard _canAddExtraURLs else {
            completion(nil)
            return
        }

        let isModeChosen = Settings.current.autoFillContextSavingModeChosenTimestamp != nil
        guard isModeChosen else {
            completion(nil)
            return
        }
        let mode = Settings.current.autoFillContextSavingMode
        let contextURL = _searchContext.getRepresentativeURL(mode: mode)
        completion(contextURL)
    }

    internal func _makeRememberContextMenu(target entry: Entry) -> UIMenu? {
        let settings = Settings.current
        let remembersAutomatically =
            settings.autoFillContextSavingModeChosenTimestamp != nil &&
            settings.autoFillContextSavingMode != .inactive
        guard _canAddExtraURLs,
              let contextURL = _searchContext.getRepresentativeURL(),
              !remembersAutomatically
        else {
            return nil
        }

        let addExtraURLAction = UIAction(title: LString.actionAcceptAndRemember) {
            [weak self, weak entry] _ in
            guard let self, let entry else { return }
            _notifyEntrySelected(entry, rememberURL: contextURL)
        }
        return UIMenu(options: .displayInline, children: [addExtraURLAction])
    }
}
