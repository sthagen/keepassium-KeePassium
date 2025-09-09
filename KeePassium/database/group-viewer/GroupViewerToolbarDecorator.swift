//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

enum GroupViewerToolbarMode {
    case normal(showsSearchResults: Bool)
    case bulkEdit(showsSearchResults: Bool, selectedItems: [DatabaseItem])
}

protocol GroupViewerToolbarDecorator: AnyObject {
    func getToolbarItems(mode: GroupViewerToolbarMode) -> [UIBarButtonItem]?
    func getLeftBarButtonItems(mode: GroupViewerToolbarMode) -> [UIBarButtonItem]?
    func getRightBarButtonItems(mode: GroupViewerToolbarMode) -> [UIBarButtonItem]?
}
