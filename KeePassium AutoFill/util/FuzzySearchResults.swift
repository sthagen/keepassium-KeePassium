//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import AuthenticationServices
import DomainParser
import KeePassiumLib

struct FuzzySearchResults {
    var exactMatch: SearchResults
    var partialMatch: SearchResults

    var isEmpty: Bool { return exactMatch.isEmpty && partialMatch.isEmpty }

    var perfectMatch: Entry? {
        guard exactMatch.count == 1,
              let theOnlyGroup = exactMatch.first,
              theOnlyGroup.scoredItems.count == 1,
              let theOnlyScoredEntry = theOnlyGroup.scoredItems.first?.item as? Entry
        else {
            return nil
        }
        return theOnlyScoredEntry
    }
}
