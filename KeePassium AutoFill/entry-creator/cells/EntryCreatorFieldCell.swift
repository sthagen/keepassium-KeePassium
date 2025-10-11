//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

struct EntryCreatorFieldConfiguration: Hashable {
    enum Kind: Hashable {
        case text
        case username
        case password(hidden: Bool)
        case url
    }

    var name: String
    var value: String
    var kind: Kind

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
            && lhs.value == rhs.value
            && lhs.kind == rhs.kind
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
        hasher.combine(kind)
    }
}

class EntryCreatorFieldCell: UICollectionViewListCell {
    protocol Delegate: AnyObject {
        func didChangeText(_ newText: String, in fieldName: String)
        func didPressEnter(in fieldName: String)
        func didChangeVisibility(of fieldName: String, isHidden: Bool)
    }

    weak var delegate: (any Delegate)?

    private var fieldName: String = ""
    private let titleLabel = UILabel()
    fileprivate var textField: ValidatingTextField!
    private let actionButton = UIButton()
    private var textFieldToEdgeConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    func configure(
        with configuration: EntryCreatorFieldConfiguration,
        actionMenu: UIMenu?
    ) {
        let password = configuration.value
        fieldName = configuration.name
        titleLabel.text = EntryField.getVisibleName(for: configuration.name)
        textField.text = password
        updateActionButton(menu: actionMenu)

        textField.accessibilityLabel = titleLabel.text
        titleLabel.isAccessibilityElement = false

        textField.font = .preferredFont(forTextStyle: .body)
        textField.keyboardType = .default
        textField.textContentType = .none
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        switch configuration.kind {
        case .text:
            break
        case .username:
            textField.keyboardType = .emailAddress
            textField.textContentType = .username
            textField.autocorrectionType = .default
            textField.autocapitalizationType = .none
        case .password(let hidden):
            textField.isSecureTextEntry = hidden
            textField.font = .monospaceFont(style: .body)
            textField.keyboardType = .default
            textField.textContentType = .password
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        case .url:
            textField.keyboardType = .URL
            textField.textContentType = .URL
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }

        let focusGroupID = "field-cell-\(configuration.name)"
        textField.focusGroupIdentifier = focusGroupID
        actionButton.focusGroupIdentifier = focusGroupID
    }

    override var canBecomeFocused: Bool { false }

    override var preferredFocusEnvironments: [any UIFocusEnvironment] {
        return [textField, actionButton]
    }

    private func setupUI() {
        contentView.preservesSuperviewLayoutMargins = true

        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        textField = makeTextField()
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = .label
        textField.validBackgroundColor = .tertiarySystemBackground
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.addSubview(textField)

        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.contentInsets = .init(top: 16, leading: 8, bottom: 16, trailing: 8)
        actionButton.configuration = buttonConfig
        actionButton.isHidden = true
        actionButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .vertical)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),

            actionButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            actionButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
        ])

        textFieldToEdgeConstraint = textField.trailingAnchor
            .constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)

        separatorLayoutGuide.leadingAnchor.constraint(equalTo: trailingAnchor).activate()

        contentView.accessibilityElements = [textField!, actionButton]
    }

    fileprivate func makeTextField() -> ValidatingTextField {
        return ValidatingTextField()
    }

    private func updateActionButton(menu: UIMenu?) {
        guard let menu else {
            actionButton.isHidden = true
            textFieldToEdgeConstraint.isActive = true
            return
        }
        var config = actionButton.configuration ?? .plain()
        config.image = menu.image
        actionButton.configuration = config
        actionButton.menu = menu
        actionButton.showsMenuAsPrimaryAction = true
        actionButton.accessibilityLabel = menu.title
        actionButton.isHidden = false
        textFieldToEdgeConstraint.isActive = false
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        var bgConfig = defaultBackgroundConfiguration().updated(for: state)
        bgConfig.backgroundColorTransformer = .init { _ in .clear }
        self.backgroundConfiguration = bgConfig
    }
}

extension EntryCreatorFieldCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.didChangeText(textField.text ?? "", in: fieldName)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.didPressEnter(in: fieldName)
        return false
    }
}

final class EntryCreatorProtectedFieldCell: EntryCreatorFieldCell {
    private var protectedTextField: ProtectedTextField { textField as! ProtectedTextField }

    override func makeTextField() -> ValidatingTextField {
        return ProtectedTextField()
    }

    override func configure(with configuration: EntryCreatorFieldConfiguration, actionMenu: UIMenu?) {
        super.configure(with: configuration, actionMenu: actionMenu)
        protectedTextField.onSecureTextEntryChanged = { [weak self] isSecureTextEntry in
            self?.delegate?.didChangeVisibility(of: configuration.name, isHidden: isSecureTextEntry)
        }
    }
}
