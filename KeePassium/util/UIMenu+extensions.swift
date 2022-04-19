//  KeePassium Password Manager
//  Copyright © 2018–2022 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

extension UIMenu {
    
    public static func make(
        title: String = "",
        reverse: Bool = false,
        options: UIMenu.Options = [],
        macOptions: UIMenu.Options? = nil,
        children: [UIMenuElement]
    ) -> UIMenu {
        if ProcessInfo.isRunningOnMac {
            return UIMenu(
                title: title,
                options: macOptions ?? options,
                children: children)
        } else {
            return UIMenu(
                title: title,
                options: options,
                children: reverse ? children.reversed() : children)
        }
    }
    
    public static func makeFileSortMenuItems(
        current: Settings.FilesSortOrder,
        handler: @escaping (Settings.FilesSortOrder) -> Void
    ) -> [UIMenuElement] {
        let sortByNone = UIAction(
            title: LString.titleSortByNone,
            attributes: [],
            state: (current == .noSorting) ? .on : .off,
            handler: { _ in
                handler(.noSorting)
            }
        )
        
        let sortByName = makeFileSortAction(
            title: LString.titleSortByFileName,
            current: current,
            ascending: .nameAsc,
            descending: .nameDesc,
            handler: handler
        )
        let sortByDateCreated = makeFileSortAction(
            title: LString.titleSortByDateCreated,
            current: current,
            ascending: .creationTimeAsc,
            descending: .creationTimeDesc,
            handler: handler
        )
        let sortByDateModified = makeFileSortAction(
            title: LString.titleSortByDateModified,
            current: current,
            ascending: .modificationTimeAsc,
            descending: .modificationTimeDesc,
            handler: handler
        )

        return [sortByNone, sortByName, sortByDateCreated, sortByDateModified]
    }
    
    private static func makeFileSortAction(
        title: String,
        current: Settings.FilesSortOrder,
        ascending: Settings.FilesSortOrder,
        descending: Settings.FilesSortOrder,
        handler: @escaping (Settings.FilesSortOrder) -> Void
    ) -> UIAction {
        switch current {
        case ascending:
            return UIAction(
                title: title,
                image: UIImage.get(.chevronUp),
                attributes: [],
                state: .on,
                handler: { _ in handler(descending) }
            )
        case descending:
            return UIAction(
                title: title,
                image: UIImage.get(.chevronDown),
                attributes: [],
                state: .on,
                handler: { _ in handler(ascending) }
            )
        default:
            return UIAction(
                title: title,
                image: nil,
                attributes: [],
                state: .off,
                handler: { _ in
                    if current.isAscending ?? true {
                        handler(ascending)
                    } else {
                        handler(descending)
                    }
                }
            )
        }
    }
    
    public static func makeDatabaseItemSortMenuItems(
        current: Settings.GroupSortOrder,
        handler: @escaping (Settings.GroupSortOrder) -> Void
    ) -> [UIMenuElement] {
        let sortByNone = UIAction(
            title: LString.titleSortByNone,
            attributes: [],
            state: (current == .noSorting) ? .on : .off,
            handler: { _ in
                handler(.noSorting)
            }
        )
        
        let sortByItemTitle = makeGroupSortAction(
            title: LString.titleSortByItemTitle,
            current: current,
            ascending: .nameAsc,
            descending: .nameDesc,
            handler: handler
        )
        let sortByDateCreated = makeGroupSortAction(
            title: LString.titleSortByDateCreated,
            current: current,
            ascending: .creationTimeAsc,
            descending: .creationTimeDesc,
            handler: handler
        )
        let sortByDateModified = makeGroupSortAction(
            title: LString.titleSortByDateModified,
            current: current,
            ascending: .modificationTimeAsc,
            descending: .modificationTimeDesc,
            handler: handler
        )
        return [sortByNone, sortByItemTitle, sortByDateCreated, sortByDateModified]
    }
    
    private static func makeGroupSortAction(
        title: String,
        current: Settings.GroupSortOrder,
        ascending: Settings.GroupSortOrder,
        descending: Settings.GroupSortOrder,
        handler: @escaping (Settings.GroupSortOrder) -> Void
    ) -> UIAction {
        switch current {
        case ascending:
            return UIAction(
                title: title,
                image: UIImage.get(.chevronUp),
                attributes: [],
                state: .on,
                handler: { _ in handler(descending) }
            )
        case descending:
            return UIAction(
                title: title,
                image: UIImage.get(.chevronDown),
                attributes: [],
                state: .on,
                handler: { _ in handler(ascending) }
            )
        default:
            return UIAction(
                title: title,
                image: nil,
                attributes: [],
                state: .off,
                handler: { _ in
                    if current.isAscending ?? true {
                        handler(ascending)
                    } else {
                        handler(descending)
                    }
                }
            )
        }
    }
}
