//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import Foundation
import SwiftCBOR

extension KeyValuePairs where Key: CBOREncodable, Value: CBOREncodable {
    func encode(useStringKeys: Bool) -> Data {
        assert(self.count < 32, "Too many keys for CBOR map")
        var result: [UInt8] = []
        result.append(0b101_00000 | UInt8(self.count & 0x1F))
        let cborOptions = CBOROptions(useStringKeys: useStringKeys)
        self.forEach { key, value in
            result.append(contentsOf: key.encode(options: cborOptions))
            result.append(contentsOf: value.encode(options: cborOptions))
        }
        return Data(result)
    }
}
