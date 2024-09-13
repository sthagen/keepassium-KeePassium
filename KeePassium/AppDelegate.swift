//  KeePassium Password Manager
//  Copyright © 2018–2024 KeePassium Labs <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

@available(iOS 13, *)
enum MenuIdentifier {
    static let databaseFileMenu = UIMenu.Identifier("com.keepassium.menu.databaseFileMenu")
    static let databaseItemsMenu = UIMenu.Identifier("com.keepassium.menu.databaseItemsMenu")
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var mainCoordinator: MainCoordinator!

    #if targetEnvironment(macCatalyst)
    private var macUtils: MacUtils?
    #endif

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initAppGlobals(application)

        let window = UIWindow(frame: UIScreen.main.bounds)
        let args = ProcessInfo.processInfo.arguments
        if args.contains("darkMode") {
            window.overrideUserInterfaceStyle = .dark
        }

        let incomingURL: URL? = launchOptions?[.url] as? URL
        let hasIncomingURL = incomingURL != nil

        var proposeAppReset = false
        #if targetEnvironment(macCatalyst)
        loadMacUtilsPlugin()
        if let macUtils, macUtils.isControlKeyPressed() {
            proposeAppReset = true
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneWillDeactivate),
            name: UIScene.willDeactivateNotification,
            object: nil
        )
        #endif

        if UIDevice.current.userInterfaceIdiom == .pad {
            window.makeKeyAndVisible()
            mainCoordinator = MainCoordinator(window: window)
            mainCoordinator.start(hasIncomingURL: hasIncomingURL, proposeReset: proposeAppReset)
        } else {
            mainCoordinator = MainCoordinator(window: window)
            mainCoordinator.start(hasIncomingURL: hasIncomingURL, proposeReset: proposeAppReset)
            window.makeKeyAndVisible()
        }

        self.window = window

        return true
    }

    private func initAppGlobals(_ application: UIApplication) {
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PremiumManager.shared.finishObservingTransactions()
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        let result = mainCoordinator.processIncomingURL(
            url,
            sourceApp: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            openInPlace: options[.openInPlace] as? Bool)
        return result
    }

    #if targetEnvironment(macCatalyst)
    private func loadMacUtilsPlugin() {
        let bundleFileName = "MacUtils.bundle"
        guard let bundleURL = Bundle.main.builtInPlugInsURL?.appendingPathComponent(bundleFileName) else {
            Diag.error("Failed to find MacUtils plugin, macOS-specific functions will be limited")
            return
        }

        guard let bundle = Bundle(url: bundleURL) else {
            Diag.error("Failed to load MacUtils plugin, macOS-specific functions will be limited")
            return
        }

        let className = "MacUtils.MacUtilsImpl"
        guard let pluginClass = bundle.classNamed(className) as? MacUtils.Type else {
            Diag.error("Failed to instantiate MacUtils plugin, macOS-specific functions will be limited")
            return
        }

        macUtils = pluginClass.init()
    }

    @objc
    private func sceneWillDeactivate(_ notification: Notification) {
        macUtils?.disableSecureEventInput()
    }
    #endif
}

extension AppDelegate {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(createDatabase):
            return mainCoordinator.canPerform(action: .createDatabase)
        case #selector(openDatabase):
            return mainCoordinator.canPerform(action: .openDatabase)
        case #selector(showAboutScreen):
            return mainCoordinator.canPerform(action: .showAboutScreen)
        case #selector(showSettingsScreen):
            return mainCoordinator.canPerform(action: .showAppSettings)
        case #selector(lockDatabase):
            return mainCoordinator.canPerform(action: .lockDatabase)
        case #selector(createEntry):
            return mainCoordinator.canPerform(action: .createEntry)
        case #selector(createGroup):
            return mainCoordinator.canPerform(action: .createGroup)
        case #selector(showAppHelp):
            return true
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }

    @available(iOS 13, *)
    override func buildMenu(with builder: UIMenuBuilder) {
        guard builder.system == UIMenuSystem.main else {
            return
        }

        builder.remove(menu: .format)
        builder.remove(menu: .openRecent)
        builder.remove(menu: .spelling)
        builder.remove(menu: .spellingOptions)
        builder.remove(menu: .spellingPanel)
        builder.remove(menu: .substitutions)
        builder.remove(menu: .substitutionOptions)
        builder.remove(menu: .transformations)
        builder.remove(menu: .speech)
        builder.remove(menu: .toolbar)

        builder.replaceChildren(ofMenu: .standardEdit) { children -> [UIMenuElement] in
            children.filter {
                ($0 as? UIKeyCommand)?.action != #selector(UIResponderStandardEditActions.pasteAndMatchStyle(_:))
            }
        }

        let aboutAppMenuTitle = builder.menu(for: .about)?.children.first?.title
            ?? String.localizedStringWithFormat(LString.menuAboutAppTemplate, AppInfo.name)
        let aboutAppMenuAction = UICommand(
            title: aboutAppMenuTitle,
            action: #selector(showAboutScreen))
        let aboutAppMenu = UIMenu(
            title: "",
            identifier: .about,
            options: .displayInline,
            children: [aboutAppMenuAction]
        )
        builder.remove(menu: .about)
        builder.insertChild(aboutAppMenu, atStartOfMenu: .application)

        let preferencesMenuItem = UIKeyCommand(
            title: builder.menu(for: .preferences)?.children.first?.title ?? LString.menuPreferences,
            action: #selector(showSettingsScreen),
            input: ",",
            modifierFlags: [.command])
        let preferencesMenu = UIMenu(
            identifier: .preferences,
            options: .displayInline,
            children: [preferencesMenuItem]
        )
        builder.remove(menu: .preferences)
        builder.insertSibling(preferencesMenu, afterMenu: .about)

        let createDatabaseMenuItem = UIKeyCommand(
            title: LString.titleNewDatabase,
            action: #selector(createDatabase),
            input: "n",
            modifierFlags: [.command, .shift])
        let openDatabaseMenuItem = UIKeyCommand(
            title: LString.actionOpenDatabase,
            action: #selector(openDatabase),
            input: "o",
            modifierFlags: [.command])
        let lockDatabaseMenuItem = UIKeyCommand(
            title: LString.actionLockDatabase,
            action: #selector(lockDatabase),
            input: "l",
            modifierFlags: [.command]
        )
        let databaseFileMenu = UIMenu(
            identifier: MenuIdentifier.databaseFileMenu,
            options: [.displayInline],
            children: [createDatabaseMenuItem, openDatabaseMenuItem, lockDatabaseMenuItem]
        )

        let createEntryMenuItem = UIKeyCommand(
            title: LString.titleNewEntry,
            action: #selector(createEntry),
            input: "n",
            modifierFlags: [.command])
        let createGroupMenuItem = UIKeyCommand(
            title: LString.titleNewGroup,
            action: #selector(createGroup),
            input: "g",
            modifierFlags: [.command])
        let databaseItemsMenu = UIMenu(
            identifier: MenuIdentifier.databaseItemsMenu,
            options: [.displayInline],
            children: [createEntryMenuItem, createGroupMenuItem]
        )

        builder.insertChild(databaseFileMenu, atStartOfMenu: .file)
        builder.insertSibling(databaseItemsMenu, beforeMenu: databaseFileMenu.identifier)
    }

    @objc
    private func showAppHelp() {
        UIApplication.shared.open(URL.AppHelp.helpIndex, options: [:], completionHandler: nil)
    }

    @objc
    private func showAboutScreen() {
        mainCoordinator.perform(action: .showAboutScreen)
    }

    @objc
    private func showSettingsScreen() {
        mainCoordinator.perform(action: .showAppSettings)
    }

    @objc
    private func createDatabase() {
        mainCoordinator.perform(action: .createDatabase)
    }

    @objc
    private func openDatabase() {
        mainCoordinator.perform(action: .openDatabase)
    }

    @objc
    private func lockDatabase() {
        mainCoordinator.perform(action: .lockDatabase)
    }

    @objc
    private func createEntry() {
        mainCoordinator.perform(action: .createEntry)
    }

    @objc
    private func createGroup() {
        mainCoordinator.perform(action: .createGroup)
    }
}

extension LString {
    public static let menuAboutAppTemplate = NSLocalizedString(
        "[Menu/About/title]",
        value: "About %@",
        comment: "Menu title. For example: `About KeePassium`. [appName: String]"
    )
    public static let menuPreferences = NSLocalizedString(
        "[Menu/Preferences/title]",
        value: "Preferences…",
        comment: "Menu title: app settings"
    )
}
