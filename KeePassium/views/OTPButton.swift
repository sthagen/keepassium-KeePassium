//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class OTPButton: UIButton {
    private let refreshInterval: TimeInterval = 1
    private let warningInterval: TimeInterval = 10
    private let normalColor: UIColor = .actionTint
    private let expiringColor: UIColor = .warningMessage

    private let generator: TOTPGenerator
    private let protected: Bool
    private let tapHandler: ((_ otpCode: String) -> Void)?
    private var refreshTimer: DispatchSourceTimer!

    init(generator: TOTPGenerator, protected: Bool, onTap: ((_ otpCode: String) -> Void)?) {
        self.generator = generator
        self.protected = protected
        self.tapHandler = onTap
        super.init(frame: .zero)

        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        addAction(
            UIAction { [unowned self] _ in tapHandler?(generator.generate()) },
            for: .touchUpInside)

        refreshTimer = DispatchSource.makeTimerSource(queue: .main)
        refreshTimer.schedule(deadline: .now(), repeating: refreshInterval)
        refreshTimer.setEventHandler { [weak self] in
            self?.refresh()
        }
        refreshTimer.resume()

        refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        refreshTimer.cancel()
        refreshTimer = nil
    }

    private func refresh() {
        let otpValue = generator.generate()
        let remainingTime = generator.remainingTime

        var config = UIButton.Configuration.plain()
        config.titleAlignment = .center
        config.titleLineBreakMode = .byClipping
        if protected {
            config.baseForegroundColor = normalColor
            config.title = nil
            config.image = .symbol(.oneTimePassword)
            accessibilityLabel = LString.fieldOTP
            accessibilityHint = LString.A11y.hintActivateToListen
        } else {
            config.image = nil
            config.attributedTitle = OTPCodeFormatter.decorateAttributed(
                otpCode: otpValue,
                font: .monospaceFont(style: .title3))
            config.contentInsets.trailing = 0
            if remainingTime <= warningInterval {
                config.baseForegroundColor = expiringColor
                let ticToc = remainingTime.truncatingRemainder(dividingBy: 2) - 1
                warningAnimation2(ticToc)
            } else {
                config.baseForegroundColor = normalColor
                layer.removeAnimation(forKey: "warning")
                layer.shadowRadius = 0
                layer.shadowOpacity = 0
                layer.opacity = 1
            }
            accessibilityLabel = otpValue
        }
        self.configuration = config
    }

    private func warningAnimation2(_ ticToc: Double) {
        let opacity: Float = ticToc > 0 ? 0.7 : 0

        layer.shadowOffset = .zero
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowColor = expiringColor.cgColor
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: { [weak self] in
                self?.layer.shadowOpacity = opacity
            },
            completion: nil
        )
    }
}
