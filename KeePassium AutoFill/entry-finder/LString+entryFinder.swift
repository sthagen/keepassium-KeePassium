//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension LString {
    // swiftlint:disable:next superfluous_disable_command
    // swiftlint:disable line_length
    public static let callToActionActivateQuickAutoFill = NSLocalizedString(
        "[QuickAutoFill/Activate/callToAction]",
        value: "Activate Quick AutoFill",
        comment: "Call to action, invites the user to enable the Quick AutoFill feature")

    public static let titleAutoFillContext = NSLocalizedString(
        "[AutoFill/Search/Context/title]",
        value: "Context",
        comment: "Title for referring to the app or webpage that launched AutoFill. For example: `Context: google.com`")

    public static let callToActionSelectField = NSLocalizedString(
        "[AutoFill/InsertText/select]",
        value: "Select Field",
        comment: "Call for action to select an entry field for filling out."
    )

    public static let autoCopyMenuTitle = NSLocalizedString(
        "[AutoFill/Search/autoCopyMenuTitle]",
        value: "Auto-copy to Clipboard",
        comment: "Title for the menu that allows selecting a field to be copied to clipboard automatically."
    )

    public static let autoFillRecentlyUsedSectionTitle = NSLocalizedString(
        "[AutoFill/RecentlyUsed/title]",
        value: "Recently Used",
        comment: "Section title for the recently used entry in AutoFill"
    )
    public static let autoFillAllEntriesSectionTitle = NSLocalizedString(
        "[AutoFill/AllEntries/title]",
        value: "All Entries",
        comment: "Title of a list"
    )
    public static let autoFillFoundEntriesSectionTitle = NSLocalizedString(
        "[AutoFill/FoundEntries/title]",
        value: "Best Matches",
        comment: "Title of a list with search results"
    )

    public static let titleNothingSuitableFound = NSLocalizedString(
        "[Search/EmptyResult/title]",
        value: "Nothing suitable found",
        comment: "Placeholder text for empty search results"
    )

    public static let titleAutoFillContextUnknown = NSLocalizedString(
        "[AutoFill/Context/Empty/title]",
        value: "Unknown",
        comment: "Title of AutoFill context when no context is available. Usage: `Context: Unknown`"
    )
    public static let rememberAutoFillContextCallToAction = NSLocalizedString(
        "[AutoFill/RememberContext/callToAction]",
        value: "Improve AutoFill suggestions",
        comment: "Call to action"
    )
    public static let rememberAutoFillContextDescription = NSLocalizedString(
        "[AutoFill/RememberContext/description]",
        value: "KeePassium will remember which entry you select for each website and then suggest it automatically.",
        comment: "Description of the 'Remember Selected Entries` feature"
    )
    public static let actionRememberAutoFillContext = NSLocalizedString(
        "[AutoFill/RememberContext/action]",
        value: "Remember Selected Entries",
        comment: "Not an action, but a button to activate the same-named setting"
    )
    public static let actionAcceptAndRemember = NSLocalizedString(
        "[AutoFill/AcceptAndRemember/action]",
        value: "Accept and Remember",
        comment: "Action in AutoFill: choose the entry and remember it for future use on this website."
    )
    // swiftlint:enable line_length
}
