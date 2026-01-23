//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

@testable import KeePassiumLib
import XCTest

final class SitePasswordRulesTests: XCTestCase {

    func testRulesDictionaryExists() {
        XCTAssertFalse(PasswordGeneratorParams.siteSpecific.isEmpty, "Password rules dictionary should not be empty")
        XCTAssertGreaterThan(PasswordGeneratorParams.siteSpecific.count, 300, "Should have hundreds of rules")
    }

    func testAppleComRule() {
        guard let rule = PasswordGeneratorParams.siteSpecific["apple.com"] else {
            XCTFail("apple.com rule should exist")
            return
        }

        XCTAssertEqual(rule.length, 32, "Apple requires max 63 chars, capped at 32")
        XCTAssertEqual(rule.fixedSets[.lowerCase], .allowed)
        XCTAssertEqual(rule.fixedSets[.upperCase], .allowed)
        XCTAssertEqual(rule.fixedSets[.digits], .allowed)
        XCTAssertEqual(rule.fixedSets[.specials], .allowed)
        XCTAssertTrue(rule.customLists.isEmpty, "Apple doesn't use custom character lists")
    }

    func testSamsungRule() {
        guard let rule = PasswordGeneratorParams.siteSpecific["account.samsung.com"] else {
            XCTFail("account.samsung.com rule should exist")
            return
        }

        XCTAssertEqual(rule.length, 15, "Samsung max length is 15")
        XCTAssertEqual(rule.fixedSets[.lowerCase], .required, "Samsung requires lowercase")
        XCTAssertEqual(rule.fixedSets[.upperCase], .required, "Samsung requires uppercase")
        XCTAssertEqual(rule.fixedSets[.digits], .required, "Samsung requires digits")
        XCTAssertEqual(rule.fixedSets[.specials], .required, "Samsung requires special chars")
    }

    func testAdmiralComCustomCharacters() {
        guard let rule = PasswordGeneratorParams.siteSpecific["admiral.com"] else {
            XCTFail("admiral.com rule should exist")
            return
        }

        XCTAssertEqual(rule.fixedSets[.digits], .required)
        XCTAssertEqual(rule.fixedSets[.lowerCase], .allowed)
        XCTAssertEqual(rule.fixedSets[.upperCase], .allowed)

        guard let customChars = rule.customLists[.required] else {
            XCTFail("admiral.com should have custom required characters")
            return
        }

        XCTAssertTrue(customChars.contains("]"), "Should contain literal ] character")
        XCTAssertTrue(customChars.contains("-"), "Should contain -")
        XCTAssertTrue(customChars.contains("!"), "Should contain !")
        XCTAssertTrue(customChars.contains("@"), "Should contain @")
    }

    func testAeonCoJpCustomCharacters() {
        guard let rule = PasswordGeneratorParams.siteSpecific["aeon.co.jp"] else {
            XCTFail("aeon.co.jp rule should exist")
            return
        }

        XCTAssertEqual(rule.length, 8, "Aeon max length is 8")
        XCTAssertEqual(rule.maxConsecutive, 3, "Aeon allows max 3 consecutive chars")
        XCTAssertEqual(rule.fixedSets[.upperCase], .required)
        XCTAssertEqual(rule.fixedSets[.lowerCase], .required)
        XCTAssertEqual(rule.fixedSets[.digits], .required)

        guard let customChars = rule.customLists[.required] else {
            XCTFail("aeon.co.jp should have custom required characters")
            return
        }

        XCTAssertTrue(customChars.contains("#"))
        XCTAssertTrue(customChars.contains("$"))
        XCTAssertTrue(customChars.contains("@"))
        XCTAssertTrue(customChars.contains("]"), "Should contain literal ] character from ]]")
    }

    func testGeneratePasswordForApple() {
        guard let rule = PasswordGeneratorParams.siteSpecific["apple.com"] else {
            XCTFail("apple.com rule should exist")
            return
        }

        let requirements = rule.toRequirements()
        let password = try? PasswordGenerator().generate(with: requirements)

        XCTAssertNotNil(password, "Should generate password for Apple")
        XCTAssertEqual(password?.count, 32, "Password should be 32 characters")
    }

    func testGeneratePasswordForSamsung() {
        guard let rule = PasswordGeneratorParams.siteSpecific["account.samsung.com"] else {
            XCTFail("account.samsung.com rule should exist")
            return
        }

        let requirements = rule.toRequirements()
        let password = try? PasswordGenerator().generate(with: requirements)

        XCTAssertNotNil(password, "Should generate password for Samsung")
        XCTAssertEqual(password?.count, 15, "Password should be 15 characters")

        guard let pwd = password else { return }

        XCTAssertTrue(pwd.contains(where: { $0.isLowercase }), "Should contain lowercase")
        XCTAssertTrue(pwd.contains(where: { $0.isUppercase }), "Should contain uppercase")
        XCTAssertTrue(pwd.contains(where: { $0.isNumber }), "Should contain digit")
    }

    func testGeneratePasswordWithCustomCharacters() {
        guard let rule = PasswordGeneratorParams.siteSpecific["admiral.com"] else {
            XCTFail("admiral.com rule should exist")
            return
        }

        let requirements = rule.toRequirements()
        let password = try? PasswordGenerator().generate(with: requirements)

        XCTAssertNotNil(password, "Should generate password with custom characters")

        guard let pwd = password else { return }

        XCTAssertTrue(pwd.contains(where: { $0.isNumber }), "Should contain digit")
    }

    func testMaxConsecutiveRule() {
        guard let rule = PasswordGeneratorParams.siteSpecific["aeon.co.jp"] else {
            XCTFail("aeon.co.jp rule should exist")
            return
        }

        XCTAssertEqual(rule.maxConsecutive, 3, "Aeon allows max 3 consecutive characters")

        let requirements = rule.toRequirements()
        XCTAssertEqual(requirements.maxConsecutive, 3, "Requirements should have maxConsecutive = 3")
    }

    func testNonExistentDomain() {
        let rule = PasswordGeneratorParams.siteSpecific["this-domain-definitely-does-not-exist.com"]
        XCTAssertNil(rule, "Non-existent domain should return nil")
    }

    func testAllRulesAreValid() {
        var failedDomains: [String] = []

        for (domain, rule) in PasswordGeneratorParams.siteSpecific {
            if rule.length < 4 || rule.length > 128 {
                failedDomains.append("\(domain): invalid length \(rule.length)")
            }

            let requirements = rule.toRequirements()
            do {
                let password = try PasswordGenerator().generate(with: requirements)
                if password.count != rule.length {
                    failedDomains.append("\(domain): generated password length mismatch")
                }
            } catch {
                failedDomains.append("\(domain): failed to generate - \(error)")
            }
        }

        if !failedDomains.isEmpty {
            XCTFail("Failed domains:\n" + failedDomains.joined(separator: "\n"))
        }
    }

    func testCommonDomainsExist() {
        let commonDomains = [
            "apple.com",
            "google.com",
            "microsoft.com",
            "netflix.com",
            "twitter.com"
        ]

        for domain in commonDomains {
            XCTAssertNotNil(
                PasswordGeneratorParams.siteSpecific[domain],
                "\(domain) should have password rules"
            )
        }
    }
}
