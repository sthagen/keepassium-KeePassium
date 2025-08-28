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
        guard let scene = UIApplication.shared.currentScene else {
            assertionFailure()
            return
        }
        let toolbar = NSToolbar(identifier: "main")
        _toolbarDelegate = MainToolbarDelegate(mainCoordinator: self)
        toolbar.delegate = _toolbarDelegate
        if #available(macCatalyst 18.0, *) {
            toolbar.autosavesConfiguration = toolbar.allowsDisplayModeCustomization
        } else {
            toolbar.displayMode = .iconOnly
        }

        let titlebar = scene.titlebar
        titlebar?.toolbar = toolbar
        titlebar?.toolbarStyle = .automatic
        titlebar?.titleVisibility = .visible
        scene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 600)
    }

    internal func _removeMacToolbar() {
        let titlebar = UIApplication.shared.currentScene?.titlebar
        titlebar?.titleVisibility = .hidden
        titlebar?.toolbar = nil
    }
}
#endif
