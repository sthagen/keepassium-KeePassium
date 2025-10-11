//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol HardwareKeyPickerCoordinatorDelegate: AnyObject {
    func didSelectKey(_ hardwareKey: HardwareKey?, in coordinator: HardwareKeyPickerCoordinator)
}

final class HardwareKeyPickerCoordinator: BaseCoordinator {
    private enum Section: Int, CaseIterable {
        case noHardwareKey
        case yubiKeyNFC
        case yubiKeyMFI
        case hwKeyUSB
    }

    private var isNFCAvailable = false
    private var isMFIAvailable = false
    private var isUSBAvailable = false
    private var isMFIoverUSB = false

    weak var delegate: HardwareKeyPickerCoordinatorDelegate?

    private var selectedKey: HardwareKey?
    private let hardwareKeyPickerVC: HardwareKeyPickerVC

    override init(router: NavigationRouter) {
        hardwareKeyPickerVC = HardwareKeyPickerVC()
        super.init(router: router)
        hardwareKeyPickerVC.delegate = self
        hardwareKeyPickerVC.selectedKey = selectedKey
    }

    override func start() {
        super.start()

        isNFCAvailable = ChallengeResponseManager.instance.supportsNFC
        isMFIAvailable = ChallengeResponseManager.instance.supportsMFI
        isUSBAvailable = ChallengeResponseManager.instance.supportsUSB
        isMFIoverUSB = ChallengeResponseManager.instance.supportsMFIoverUSB
        hardwareKeyPickerVC.update(with: makeSections())

        _pushInitialViewController(hardwareKeyPickerVC, dismissButtonStyle: .cancel, animated: true)
        refresh()
    }

    override func refresh() {
        super.refresh()
        hardwareKeyPickerVC.update(with: makeSections())
    }

    private func makeSections() -> [HardwareKeyPickerSection] {
        let needsPremium = !PremiumManager.shared.isAvailable(feature: .canUseHardwareKeys)

        var sections: [HardwareKeyPickerSection] = []
        sections.append(HardwareKeyPickerSection(header: nil, footer: nil, items: [.noKey]))

        if !ProcessInfo.isRunningOnMac {
            sections.append(HardwareKeyPickerSection(
                header: LString.hardwareKeyPortNFC,
                footer: AppGroup.isAppExtension ? LString.theseHardwareKeyNotAvailableInAutoFill : nil,
                items: [
                    .keyType(.init(
                        kind: .yubikey,
                        interface: .nfc,
                        isEnabled: isNFCAvailable,
                        needsPremium: needsPremium
                    ))
                ]
            ))
            sections.append(HardwareKeyPickerSection(
                header: isMFIoverUSB ? LString.hardwareKeyPortLightningOverUSBC : LString.hardwareKeyPortLightning,
                footer: isMFIoverUSB ? LString.hardwareKeyRequiresUSBtoLightningAdapter : nil,
                items: [
                    .keyType(.init(
                        kind: .yubikey,
                        interface: .mfi,
                        isEnabled: isMFIAvailable,
                        needsPremium: needsPremium
                    ))
                ]
            ))
        }

        let usbFooterText: String?
        if ProcessInfo.isCatalystApp {
            usbFooterText = AppGroup.isAppExtension ? LString.theseHardwareKeyNotAvailableInAutoFill : nil
        } else if ProcessInfo.isiPadAppOnMac {
            usbFooterText = LString.usbUnavailableIPadAppOnMac
        } else {
            usbFooterText = LString.usbHardwareKeyNotSupported
        }
        sections.append(HardwareKeyPickerSection(
            header: LString.hardwareKeyPortUSB,
            footer: usbFooterText,
            items: [
                .keyType(.init(
                    kind: .yubikey,
                    interface: .usb,
                    isEnabled: isUSBAvailable,
                    needsPremium: needsPremium)),
                .keyType(.init(
                    kind: .onlykey,
                    interface: .usb,
                    isEnabled: isUSBAvailable,
                    needsPremium: needsPremium))
            ]
        ))

        sections.append(HardwareKeyPickerSection(
            header: nil,
            footer: nil,
            items: [.infoLink(LString.actionLearnMore)]
        ))
        return sections
    }

    func setSelectedKey(_ hardwareKey: HardwareKey?) {
        self.selectedKey = hardwareKey
        hardwareKeyPickerVC.selectedKey = hardwareKey
    }

    private func maybeSelectKey(_ hardwareKey: HardwareKey?) {
        if PremiumManager.shared.isAvailable(feature: .canUseHardwareKeys) || hardwareKey == nil {
            setSelectedKey(hardwareKey)
            delegate?.didSelectKey(hardwareKey, in: self)
            dismiss()
        } else {
            setSelectedKey(nil) // reset visual selection to "No key"
            offerPremiumUpgrade(for: .canUseHardwareKeys, in: hardwareKeyPickerVC)
        }
    }
}

extension HardwareKeyPickerCoordinator: HardwareKeyPickerVC.Delegate {
    func didSelectKey(_ hardwareKey: HardwareKey?, in picker: HardwareKeyPickerVC) {
        maybeSelectKey(hardwareKey)
    }

    func didPressLearnMore(in viewController: HardwareKeyPickerVC) {
        URLOpener(viewController).open(url: URL.AppHelp.yubikeySetup)
    }
}
