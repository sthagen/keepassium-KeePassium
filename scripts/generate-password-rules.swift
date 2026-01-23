#!/usr/bin/env swift

import Foundation

let githubURL = URL(string: "https://raw.githubusercontent.com/keepassium/password-manager-resources/master/quirks/password-rules.json")!
let outputPath = "./KeePassiumLib/KeePassiumLib/util/password-generator/PasswordGeneratorParams+siteSpecific.swift"

struct DomainRule: Codable {
    let passwordRules: String

    enum CodingKeys: String, CodingKey {
        case passwordRules = "password-rules"
    }
}

print("Downloading password rules from GitHub...")

let jsonData = try! Data(contentsOf: githubURL)
print("Downloaded \(jsonData.count) bytes")

let rulesDict = try! JSONDecoder().decode([String: DomainRule].self, from: jsonData)
print("Parsed \(rulesDict.count) rules")

struct ParsedParams {
    var length: Int = 16
    var fixedSets: [String: String] = [:]
    var customLists: [String: String] = [:]
    var maxConsecutive: Int?
}

func parsePasswordRule(_ ruleString: String) -> ParsedParams? {
    var params = ParsedParams()
    var minLength: Int?
    var maxLength: Int?

    let rules = splitByDelimiter(ruleString, delimiter: ";")

    for rule in rules {
        let parts = rule.split(separator: ":", maxSplits: 1).map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        guard parts.count == 2 else { continue }

        let key = String(parts[0])
        let value = String(parts[1])

        switch key {
        case "minlength":
            minLength = Int(value)
        case "maxlength":
            maxLength = Int(value)
        case "max-consecutive":
            params.maxConsecutive = Int(value)
        case "required":
            applyCharacterClasses(value, condition: ".required", to: &params)
        case "allowed":
            applyCharacterClasses(value, condition: ".allowed", to: &params)
        default:
            break
        }
    }

    let defaultLength = 32
    if let max = maxLength {
        params.length = min(max, defaultLength)
    } else if let min = minLength {
        params.length = max(min, defaultLength)
    }

    if params.fixedSets[".lowerCase"] == nil {
        params.fixedSets[".lowerCase"] = ".allowed"
    }
    if params.fixedSets[".upperCase"] == nil {
        params.fixedSets[".upperCase"] = ".allowed"
    }
    if params.fixedSets[".digits"] == nil {
        params.fixedSets[".digits"] = ".allowed"
    }
    if params.fixedSets[".specials"] == nil {
        params.fixedSets[".specials"] = ".allowed"
    }
    return params
}

func applyCharacterClasses(_ value: String, condition: String, to params: inout ParsedParams) {
    let classes = parseCharacterClassList(value)

    for characterClass in classes {
        if characterClass.hasPrefix("[") && characterClass.hasSuffix("]") {
            var chars = String(characterClass.dropFirst().dropLast())

            chars = chars.replacingOccurrences(of: "\\", with: "\\\\")
            chars = chars.replacingOccurrences(of: "\"", with: "\\\"")

            if let existing = params.customLists[condition] {
                params.customLists[condition] = existing + chars
            } else {
                params.customLists[condition] = chars
            }
        } else {
            switch characterClass {
            case "lower":
                params.fixedSets[".lowerCase"] = condition
            case "upper":
                params.fixedSets[".upperCase"] = condition
            case "digit":
                params.fixedSets[".digits"] = condition
            case "special":
                params.fixedSets[".specials"] = condition
            case "ascii-printable", "unicode":
                params.fixedSets[".lowerCase"] = condition
                params.fixedSets[".upperCase"] = condition
                params.fixedSets[".digits"] = condition
                params.fixedSets[".specials"] = condition
            default:
                if !characterClass.isEmpty {
                    print("Unknown character class: \(characterClass)")
                }
            }
        }
    }
}

func splitByDelimiter(_ input: String, delimiter: Character) -> [String] {
    var parts: [String] = []
    var current = ""
    var i = input.startIndex

    while i < input.endIndex {
        let ch = input[i]

        if ch == "[" {
            current.append(ch)
            i = input.index(after: i)

            while i < input.endIndex {
                let ch2 = input[i]

                if ch2 == "]" {
                    let nextIndex = input.index(after: i)
                    if nextIndex < input.endIndex && input[nextIndex] == "]" {
                        current.append("]")
                        i = input.index(after: i)
                    } else {
                        current.append("]")
                        i = input.index(after: i)
                        break
                    }
                } else {
                    current.append(ch2)
                    i = input.index(after: i)
                }
            }
        } else if ch == delimiter {
            let trimmed = current.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                parts.append(trimmed)
            }
            current = ""
            i = input.index(after: i)
        } else {
            current.append(ch)
            i = input.index(after: i)
        }
    }

    let trimmed = current.trimmingCharacters(in: .whitespaces)
    if !trimmed.isEmpty {
        parts.append(trimmed)
    }

    return parts
}

func parseCharacterClassList(_ value: String) -> [String] {
    return splitByDelimiter(value, delimiter: ",")
}

func generateSwiftCode(domain: String, params: ParsedParams) -> String {
    var code = "        \"\(domain)\": CustomPasswordGeneratorParams(\n"
    code += "            length: \(params.length),\n"
    code += "            fixedSets: [\n"

    for (set, condition) in params.fixedSets.sorted(by: { $0.key < $1.key }) {
        code += "                \(set): \(condition),\n"
    }

    code += "            ]"

    if !params.customLists.isEmpty {
        code += ",\n            customLists: [\n"
        for (condition, chars) in params.customLists.sorted(by: { $0.key < $1.key }) {
            code += "                \(condition): \"\(chars)\",\n"
        }
        code += "            ]"
    }

    if let maxConsecutive = params.maxConsecutive {
        code += ",\n            maxConsecutive: \(maxConsecutive)"
    }

    code += "\n        ),\n"

    return code
}

print("Generating Swift code...")

var output = """
    import Foundation

    extension PasswordGeneratorParams {
        public static let siteSpecific: [String: CustomPasswordGeneratorParams] = [

    """

for (domain, rule) in rulesDict.sorted(by: { $0.key < $1.key }) {
    if let params = parsePasswordRule(rule.passwordRules) {
        output += generateSwiftCode(domain: domain, params: params)
    } else {
        print("Failed to parse rule for \(domain): \(rule.passwordRules)")
    }
}

output += """
    ]
}

"""

try! output.write(toFile: outputPath, atomically: true, encoding: .utf8)
print("Generated password rules to \(outputPath)")
print("File size: \((output.utf8.count / 1024)) KB")
