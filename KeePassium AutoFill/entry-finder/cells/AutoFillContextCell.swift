//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

final class AutoFillContextCell: UICollectionViewListCell {
    private var value: String = ""
    private var copyButton: UIButton!

    static func makeRegistration() -> UICollectionView.CellRegistration<AutoFillContextCell, String> {
        UICollectionView.CellRegistration<AutoFillContextCell, String> {
            cell, indexPath, text in
            cell.configure(with: text)
        }
    }

    func configure(with value: String) {
        self.value = value

        var config = UIListContentConfiguration.valueCell()
        if value.isEmpty {
            config.text = LString.titleAutoFillContextUnknown
            config.textProperties.font = .preferredFont(forTextStyle: .body).addingTraits(.traitItalic)
            config.textProperties.color = .secondaryLabel
        } else {
            config.text = value
            config.textProperties.font = .preferredFont(forTextStyle: .body)
            config.textProperties.color = .label
        }
        config.textProperties.lineBreakMode = .byCharWrapping
        config.secondaryTextProperties.color = .secondaryLabel // for "Copied" text
        config.prefersSideBySideTextAndSecondaryText = true
        self.contentConfiguration = config

        if value.isEmpty {
            accessories = []
            return
        }

        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = .symbol(.docOnDoc)
        let copyButton = UIButton(configuration: buttonConfig, primaryAction: UIAction { [weak self] _ in
            self?.didPressCopyButton()
        })
        copyButton.accessibilityLabel = LString.actionCopy
        self.copyButton = copyButton

        self.accessories = [.customView(configuration: .init(customView: copyButton, placement: .trailing()))]
    }

    private func didPressCopyButton() {
        Clipboard.general.copyWithTimeout(value)
        HapticFeedback.play(.copiedToClipboard)
        guard var config = contentConfiguration as? UIListContentConfiguration else {
            assertionFailure()
            return
        }
        config.secondaryText = LString.titleCopiedToClipboard
        self.contentConfiguration = config
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            config.secondaryText = nil
            contentConfiguration = config
        }
    }
}
