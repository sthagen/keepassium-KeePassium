//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

enum HardwareKeyPickerItem: Hashable {
    case noKey
    case keyType(KeyTypeInfo)
    case keySlot(KeySlotInfo)
    case infoLink(String)

    struct KeyTypeInfo: Hashable {
        let kind: HardwareKey.Kind
        let interface: HardwareKey.Interface
        let isEnabled: Bool
        let needsPremium: Bool

        var localizedDescription: String {
            kind.description
        }

        var availableSlots: [HardwareKey.Slot] {
            switch kind {
            case .yubikey, .onlykey:
                return [.slot1, .slot2]
            }
        }
    }

    struct KeySlotInfo: Hashable {
        let keyType: KeyTypeInfo
        let slot: HardwareKey.Slot

        var asHardwareKey: HardwareKey {
            return HardwareKey(keyType.kind, interface: keyType.interface, slot: slot)
        }
    }
}
