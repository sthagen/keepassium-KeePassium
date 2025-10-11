//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

final public class OTPCodeFormatter {

    public static func decorate(otpCode: String) -> String {
        var result = otpCode
        switch otpCode.count {
        case 5: result.insert(" ", at: String.Index(utf16Offset: 2, in: result))
        case 6: result.insert(" ", at: String.Index(utf16Offset: 3, in: result))
        case 7: result.insert(" ", at: String.Index(utf16Offset: 3, in: result))
        case 8: result.insert(" ", at: String.Index(utf16Offset: 4, in: result))
        default:
            break
        }
        return result
    }

    public static func decorateAttributed(otpCode: String, font: UIFont? = nil) -> AttributedString {
        var attributedString = AttributedString(decorate(otpCode: otpCode))
        if let font {
            attributedString.font = font
        }
        return attributedString
    }
}
