//  KeePassium Password Manager
//  Copyright © 2018–2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

public final class ManagedAppConfig: NSObject {
    public static let shared = ManagedAppConfig()

    public enum Key: String, CaseIterable {
        static let managedConfig = "com.apple.configuration.managed"

        case configVersion
        case license
        case supportEmail

        case autoUnlockLastDatabase
        case rememberDatabaseKey
        case rememberDatabaseFinalKey
        case keepKeyFileAssociations
        case keepHardwareKeyAssociations
        case lockAllDatabasesOnFailedPasscode
        case appLockTimeout
        case lockAppOnLaunch
        case databaseLockTimeout
        case lockDatabasesOnTimeout
        case lockDatabasesOnReboot
        case clipboardTimeout
        case useUniversalClipboard
        case hideProtectedFields
        case showBackupFiles
        case backupDatabaseOnSave
        case backupKeepingDuration
        case excludeBackupFilesFromSystemBackup
        case enableQuickTypeAutoFill
        case allowNetworkAccess
        case hideAppLockSetupReminder
        case allowedFileProviders
        case minimumAppPasscodeEntropy
        case minimumDatabasePasswordEntropy
        case requireAppPasscodeSet
        case allowPasswordAudit
        case allowFaviconDownload
    }

    private var currentConfig: [String: Any]? {
        guard let config = UserDefaults.standard.dictionary(forKey: Key.managedConfig) else {
            return nil
        }
        return config
    }
    private var intuneConfig: [String: Any]?
    private var previousLicenseValue: String?
    private var hasWarnedAboutMissingLicense = false
    private var allowedFileProviders: FileProviderRestrictions?

    override private init() {
        super.init()
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: nil,
            using: userDefaultsDidChange)
    }

    public func isManaged() -> Bool {
        let isForced = UserDefaults.standard.objectIsForced(forKey: Key.managedConfig)
        return isForced
    }

    private func userDefaultsDidChange(_ notification: Notification) {
        let newLicense = license
        if newLicense != previousLicenseValue {
            Diag.debug("License key changed, reloading")
            previousLicenseValue = newLicense
            hasWarnedAboutMissingLicense = false
            LicenseManager.shared.checkBusinessLicense()
        }
        guard isManaged() else { return }
        allowedFileProviders = nil
    }
}

extension ManagedAppConfig {

    public func setIntuneAppConfig(_ configurations: [[AnyHashable: Any]]?) {
        guard let configurations else {
            intuneConfig = nil
            Diag.info("No app config provided by Intune")
            return
        }
        guard var configurations = configurations as? [[String: Any]] else {
            intuneConfig = nil
            Diag.info("Unexpected Intune config type")
            return
        }

        let defaultConfigIndex = configurations.firstIndex { config in
            config["__IsDefault"] as? String == "true"
        }

        var newIntuneConfig = [String: Any]()
        if defaultConfigIndex != nil {
            newIntuneConfig = configurations.remove(at: defaultConfigIndex!)
        }
        configurations.forEach { configPart in
            newIntuneConfig.merge(configPart, uniquingKeysWith: { $1 })
        }
        intuneConfig = newIntuneConfig
        Diag.info("App configuration policy applied OK")
    }
}

extension ManagedAppConfig {
    internal var license: String? {
        let licenseValue = getString(.license)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if licenseValue == nil && BusinessModel.isIntuneEdition {
            Diag.warning("Business license is not configured")
        }
        return licenseValue
    }

    public var supportEmail: String? {
        return getString(.supportEmail)
    }

    public func isManaged(key: Key) -> Bool {
        switch key {
        case .license,
             .supportEmail:
            return getString(key) != nil
        case .autoUnlockLastDatabase,
             .rememberDatabaseKey,
             .rememberDatabaseFinalKey,
             .keepKeyFileAssociations,
             .keepHardwareKeyAssociations,
             .lockAllDatabasesOnFailedPasscode,
             .lockAppOnLaunch,
             .lockDatabasesOnTimeout,
             .lockDatabasesOnReboot,
             .useUniversalClipboard,
             .hideProtectedFields,
             .showBackupFiles,
             .backupDatabaseOnSave,
             .excludeBackupFilesFromSystemBackup,
             .enableQuickTypeAutoFill,
             .allowNetworkAccess,
             .hideAppLockSetupReminder,
             .requireAppPasscodeSet,
             .allowPasswordAudit,
             .allowFaviconDownload:
            return getBool(key) != nil
        case .configVersion,
             .appLockTimeout,
             .databaseLockTimeout,
             .clipboardTimeout,
             .backupKeepingDuration,
             .minimumAppPasscodeEntropy,
             .minimumDatabasePasswordEntropy:
            return getInt(key) != nil
        case .allowedFileProviders:
            return getStringArray(key) != nil
        }
    }

    private func warnAboutMissingLicenseOnce() {
        if hasWarnedAboutMissingLicense {
            return
        }
        Diag.warning("Could not find active business license, managed configuration won't apply.")
        hasWarnedAboutMissingLicense = true
    }

    internal func getBoolIfLicensed(_ key: Key) -> Bool? {
        let result: Bool?
        switch key {
        case .autoUnlockLastDatabase,
             .rememberDatabaseKey,
             .rememberDatabaseFinalKey,
             .keepKeyFileAssociations,
             .keepHardwareKeyAssociations,
             .lockAllDatabasesOnFailedPasscode,
             .lockAppOnLaunch,
             .lockDatabasesOnTimeout,
             .lockDatabasesOnReboot,
             .useUniversalClipboard,
             .hideProtectedFields,
             .showBackupFiles,
             .backupDatabaseOnSave,
             .excludeBackupFilesFromSystemBackup,
             .enableQuickTypeAutoFill,
             .allowNetworkAccess,
             .hideAppLockSetupReminder,
             .requireAppPasscodeSet,
             .allowPasswordAudit,
             .allowFaviconDownload:
            result = getBool(key)
        default:
            Diag.error("Key `\(key.rawValue)` is not boolean, ignoring")
            assertionFailure()
            return nil
        }

        guard result != nil else {
            return nil
        }

        guard LicenseManager.shared.hasActiveBusinessLicense() else {
            warnAboutMissingLicenseOnce()
            return nil
        }
        return result
    }

    internal func getIntIfLicensed(_ key: Key) -> Int? {
        var result: Int?
        switch key {
        case .configVersion,
             .appLockTimeout,
             .databaseLockTimeout,
             .clipboardTimeout,
             .backupKeepingDuration,
             .minimumAppPasscodeEntropy,
             .minimumDatabasePasswordEntropy:
            result = getInt(key)
        default:
            Diag.error("Key `\(key.rawValue)` is not an integer, ignoring.")
            assertionFailure()
            return nil
        }

        guard result != nil else {
            return nil
        }

        guard LicenseManager.shared.hasActiveBusinessLicense() else {
            warnAboutMissingLicenseOnce()
            return nil
        }
        return result
    }

    internal func getStringArrayIfLicensed(_ key: Key) -> [String]? {
        var result: [String]?
        switch key {
        case .allowedFileProviders:
            result = getStringArray(key)
        default:
            Diag.error("Key `\(key.rawValue)` is not a string array, ignoring.")
            assertionFailure()
            return nil
        }

        guard result != nil else {
            return nil
        }

        guard LicenseManager.shared.hasActiveBusinessLicense() else {
            warnAboutMissingLicenseOnce()
            return nil
        }
        return result
    }
}

extension ManagedAppConfig {
    private static let fileProvidersAll = "all"
    private enum FileProviderRestrictions {
        case allowAll
        case allowSome(Set<FileProvider>)
    }

    internal func isAllowed(_ fileProvider: FileProvider) -> Bool {
        if allowedFileProviders == nil {
            allowedFileProviders = parseAllowedFileProviders()
        }
        switch allowedFileProviders! {
        case .allowAll:
            return true
        case .allowSome(let allowedOnes):
            return allowedOnes.contains(fileProvider)
        }
    }

    private func parseAllowedFileProviders() -> FileProviderRestrictions {
        guard let allowedProviderIDs = getStringArrayIfLicensed(.allowedFileProviders) else {
            return .allowAll
        }
        if allowedProviderIDs.contains(Self.fileProvidersAll) {
            return .allowAll
        }

        let allowedProviders = allowedProviderIDs.compactMap {
            FileProvider(rawValue: $0)
        }
        return .allowSome(Set(allowedProviders))
    }
}

extension ManagedAppConfig {
    private func getObject(_ key: Key) -> Any? {
        let intuneConfigValue = intuneConfig?[key.rawValue]
        let appleConfigValue = currentConfig?[key.rawValue]
        let anyValue = intuneConfigValue ?? appleConfigValue
        return anyValue
    }

    private func getString(_ key: Key) -> String? {
        return getObject(key) as? String
    }

    private func getBool(_ key: Key) -> Bool? {
        let valueString = getString(key)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        switch valueString {
        case "true", "on", "1":
            return true
        case "false", "off", "0":
            return false
        default:
            return nil
        }
    }

    private func getInt(_ key: Key) -> Int? {
        guard let valueString = getString(key)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
        else {
            return nil
        }
        guard let result = Int(valueString) else {
            Diag.warning("Managed value `\(key.rawValue)` is not an Int, ignoring it.")
            return nil
        }
        return result
    }

    private func getStringArray(_ key: Key) -> [String]? {
        guard let object = getObject(key) else {
            return nil
        }
        guard let result = object as? [String] else {
            Diag.warning("Managed value `\(key.rawValue)` is not a string array, ignoring it.")
            return nil
        }
        return result
    }
}
