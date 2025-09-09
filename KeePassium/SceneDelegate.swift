//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appServices: AppServices!
    private var mainCoordinator: MainCoordinator!

    #if targetEnvironment(macCatalyst)
    var macUtils: MacUtils?
    #endif

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.appServices = appDelegate.appServices

        let window = WatchdogAwareWindow(frame: UIScreen.main.bounds)
        window.windowScene = windowScene
        let args = ProcessInfo.processInfo.arguments
        if args.contains("darkMode") {
            window.overrideUserInterfaceStyle = .dark
        }
        self.window = window

        var proposeAppReset = false
        #if targetEnvironment(macCatalyst)
        if let macUtils = appServices.macUtils,
           macUtils.isControlKeyPressed()
        {
            proposeAppReset = true
        }
        setupNSWindowStateObserver()
        #endif

        let hasIncomingURL = !connectionOptions.urlContexts.isEmpty

        mainCoordinator = MainCoordinator(window: window, autoTypeHelper: appServices.autoTypeHelper)
        mainCoordinator.start(waitForIncomingURL: hasIncomingURL, proposeReset: proposeAppReset)
        window.makeKeyAndVisible()

        appServices.mainCoordinator = mainCoordinator

        if !connectionOptions.urlContexts.isEmpty {
            self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            mainCoordinator.processIncomingURL(
                context.url,
                sourceApp: context.options.sourceApplication,
                openInPlace: context.options.openInPlace
            )
        }
    }
}

#if targetEnvironment(macCatalyst)
private extension SceneDelegate {
    private func setupNSWindowStateObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(macWindowDidResignKey),
            name: Notification.Name.nsWindowDidResignKeyNotificationName,
            object: nil)
    }

    @objc private func macWindowDidResignKey(_notification: Notification) {
        appServices.macUtils?.disableSecureEventInput()
    }
}
#endif
