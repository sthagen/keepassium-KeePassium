//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

final class AppServices {
    #if targetEnvironment(macCatalyst)
    fileprivate(set) var macUtils: MacUtils?
    #endif
    fileprivate(set) var autoTypeHelper: AutoTypeHelper?
    weak var mainCoordinator: MainCoordinator?
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
    public var appServices = AppServices()

    override var next: UIResponder? { appServices.mainCoordinator }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        #if PREPAID_VERSION
        BusinessModel.type = .prepaid
        #else
        BusinessModel.type = .freemium
        #endif

        #if INTUNE
        BusinessModel.isIntuneEdition = true
        OneDriveManager.shared.setAuthProvider(MSALOneDriveAuthProvider())
        #else
        BusinessModel.isIntuneEdition = false
        #endif

        AppGroup.applicationShared = application
        Swizzler.swizzle()

        SettingsMigrator.processAppLaunch(with: Settings.current)

        appServices = AppServices()
        #if targetEnvironment(macCatalyst)
        appServices.macUtils = loadMacUtilsPlugin()
        appServices.autoTypeHelper = AutoTypeHelper(macUtils: appServices.macUtils)
        #endif
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PremiumManager.shared.finishObservingTransactions()
    }

    #if targetEnvironment(macCatalyst)
    private func loadMacUtilsPlugin() -> MacUtils? {
        let bundleFileName = "MacUtils.bundle"
        guard let bundleURL = Bundle.main.builtInPlugInsURL?.appendingPathComponent(bundleFileName) else {
            Diag.error("Failed to find MacUtils plugin, macOS-specific functions will be limited")
            return nil
        }

        guard let bundle = Bundle(url: bundleURL) else {
            Diag.error("Failed to load MacUtils plugin, macOS-specific functions will be limited")
            return nil
        }

        let className = "MacUtils.MacUtilsImpl"
        guard let pluginClass = bundle.classNamed(className) as? MacUtils.Type else {
            Diag.error("Failed to instantiate MacUtils plugin, macOS-specific functions will be limited")
            return nil
        }

        return pluginClass.init()
    }
    #endif
}
