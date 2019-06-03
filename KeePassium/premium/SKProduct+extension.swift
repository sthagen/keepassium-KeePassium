//  KeePassium Password Manager
//  Copyright © 2018–2019 Andrei Popleteev <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import StoreKit
import UIKit

extension SKProduct {
    
    /// Price of the product in local currency.
    /// In case of locale trouble, falls back to number-only result.
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.locale = priceLocale
        formatter.numberStyle = .currency
        return formatter.string(from: price) ?? String(format: "%.2f", price)
    }
}