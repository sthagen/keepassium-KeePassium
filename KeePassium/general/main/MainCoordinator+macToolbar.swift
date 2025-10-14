//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

#if targetEnvironment(macCatalyst)
extension MainCoordinator {
    internal func _setupMacToolbar() {
        guard let scene = UIApplication.shared.currentActiveScene else {
            assertionFailure()
            return
        }
        scene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 600)
        guard let titlebar = scene.titlebar else {
            assertionFailure()
            return
        }
        titlebar.titleVisibility = .visible
        titlebar.separatorStyle = .automatic

        if _mainToolbar == nil {
            _mainToolbar = createMainToolbar()
        }

        DispatchQueue.main.async { [self] in
            titlebar.toolbar = _mainToolbar
            titlebar.toolbarStyle = .unifiedCompact
        }
    }

    internal func _removeMacToolbar() {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        scenes.forEach {
            let titlebar = $0.titlebar
            titlebar?.titleVisibility = .hidden
            titlebar?.separatorStyle = .none
            titlebar?.toolbar = nil
        }
    }

    private func createMainToolbar() -> NSToolbar {
        let toolbar = NSToolbar(identifier: "main")
        _toolbarDelegate = MainToolbarDelegate(mainCoordinator: self)
        toolbar.delegate = _toolbarDelegate
        if #available(macCatalyst 18.0, *) {
            toolbar.autosavesConfiguration = toolbar.allowsDisplayModeCustomization
        } else {
            toolbar.displayMode = .iconOnly
        }
        return toolbar
    }
}
#endif
