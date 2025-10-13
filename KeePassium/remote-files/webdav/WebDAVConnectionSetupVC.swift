//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol WebDAVConnectionSetupVCDelegate: AnyObject {
    func didPressDone(
        nakedWebdavURL: URL,
        credential: NetworkCredential,
        in viewController: WebDAVConnectionSetupVC
    )
    func didPressHelpButton(url: URL, in viewController: WebDAVConnectionSetupVC)
}

final class WebDAVConnectionSetupVC: UITableViewController {
    private enum CellID {
        static let textFieldCell = "TextFieldCell"
        static let protectedTextFieldCell = "ProtectedTextFieldCell"
        static let switchCell = "SwitchCell"
        static let buttonCell = "ButtonCell"
        static let fullUrlCell = "FullUrlCell"
    }

    private enum Section {
        case server
        case credentials
        case fullUrl
        case help
    }

    private enum ServerRow {
        case url
        case allowUntrusted
    }

    private enum CredentialsRow: Int, CaseIterable {
        case username
        case password
    }

    private var sections: [Section] {
        var sections : [Section] = []
        if config.showsServerURLField {
            sections.append(.server)
        }
        sections.append(.credentials)
        if config.showsFullURLInfo {
            sections.append(.fullUrl)
        }
        if config.showsHelpSection {
            sections.append(.help)
        }
        return sections
    }

    private var serverRows: [ServerRow] {
        var rows: [ServerRow] = []
        if config.showsServerURLField {
            rows.append(.url)
        }
        if config.showsAllowUntrusted {
            rows.append(.allowUntrusted)
        }
        return rows
    }

    weak var delegate: WebDAVConnectionSetupVCDelegate?

    private(set) var config: WebDAVConnectionSetupConfig

    private var isBusy = false

    private lazy var titleView: SpinnerLabel = {
        let view = SpinnerLabel(frame: .zero)
        view.label.text = config.title
        view.label.font = .preferredFont(forTextStyle: .headline)
        view.spinner.startAnimating()
        return view
    }()

    private var doneButton: UIBarButtonItem!
    private weak var webdavURLTextField: ValidatingTextField?
    private weak var webdavUsernameTextField: ValidatingTextField?
    private weak var webdavPasswordTextField: ValidatingTextField?

    init(config: WebDAVConnectionSetupConfig) {
        self.config = config
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    static func make(config: WebDAVConnectionSetupConfig) -> WebDAVConnectionSetupVC {
        return WebDAVConnectionSetupVC(config: config)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView

        tableView.register(SwitchCell.classForCoder(), forCellReuseIdentifier: CellID.switchCell)
        tableView.register(TextFieldCell.classForCoder(), forCellReuseIdentifier: CellID.textFieldCell)
        tableView.register(ProtectedTextFieldCell.classForCoder(), forCellReuseIdentifier: CellID.protectedTextFieldCell)
        tableView.register(ButtonCell.classForCoder(), forCellReuseIdentifier: CellID.buttonCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellID.fullUrlCell)
        tableView.alwaysBounceVertical = false

        setupDoneButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        populateFields()

        DispatchQueue.main.async {
            if self.config.showsServerURLField {
                self.webdavURLTextField?.becomeFirstResponder()
            } else {
                self.webdavUsernameTextField?.becomeFirstResponder()
            }
        }
    }

    private func setupDoneButton() {
        doneButton = UIBarButtonItem(
            title: LString.actionContinue,
            primaryAction: UIAction { [weak self] _ in
                self?.didPressDone()
            }
        )
        navigationItem.rightBarButtonItem = doneButton
    }

    private func populateFields() {
        webdavUsernameTextField?.text = config.username
        webdavPasswordTextField?.text = config.password

        if config.showsServerURLField {
            setWebdavInputURL(url: config.serverURL)
        }
    }

    private func refresh() {
        titleView.label.text = config.title
        tableView.reloadData()
        refreshDoneButton()
    }

    private func refreshDoneButton() {
        guard isViewLoaded else { return }

        doneButton.isEnabled = config.isValid && !isBusy
    }

    private func didPressDone() {
        guard doneButton.isEnabled else { return }

        guard let url = config.serverURL else {
            return
        }

        guard let credentials = NetworkCredential(config) else {
            return
        }

        delegate?.didPressDone(
            nakedWebdavURL: url,
            credential: credentials,
            in: self
        )
    }

    private func didPressHelpButton() {
        guard let helpURL = config.helpURL else { return }
        delegate?.didPressHelpButton(url: helpURL, in: self)
    }
}

extension WebDAVConnectionSetupVC: BusyStateIndicating {
    func indicateState(isBusy: Bool) {
        titleView.showSpinner(isBusy, animated: true)
        self.isBusy = isBusy
        refresh()
    }
}

extension WebDAVConnectionSetupVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .server:
            return serverRows.count
        case .credentials:
            return CredentialsRow.allCases.count
        case .help:
            return 1
        case .fullUrl:
            return 1
        }
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch sections[section] {
        case .server:
            return LString.titleServerURL
        case .credentials:
            return LString.titleCredentials
        case .fullUrl:
            return LString.titleFullURL
        case .help:
            return nil
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: getReusableCellID(for: indexPath),
            for: indexPath
        )
        resetCellStyle(cell)
        configureCell(cell, at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if sections[indexPath.section] == .help {
            didPressHelpButton()
        }
    }

    private func getReusableCellID(for indexPath: IndexPath) -> String {
        switch sections[indexPath.section] {
        case .server:
            switch serverRows[indexPath.row] {
            case .url:
                return CellID.textFieldCell
            case .allowUntrusted:
                return CellID.switchCell
            }

        case .credentials:
            switch CredentialsRow(rawValue: indexPath.row) {
            case .username:
                return CellID.textFieldCell
            case .password:
                return CellID.protectedTextFieldCell
            case .none:
                return CellID.textFieldCell
            }

        case .fullUrl:
            return CellID.fullUrlCell

        case .help:
            return CellID.buttonCell
        }
    }

    private func resetCellStyle(_ cell: UITableViewCell) {
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        cell.textLabel?.textColor = .primaryText
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .footnote)
        cell.detailTextLabel?.textColor = .auxiliaryText
        cell.imageView?.image = nil
        cell.accessoryType = .none

        cell.textLabel?.accessibilityLabel = nil
        cell.detailTextLabel?.accessibilityLabel = nil
        cell.accessibilityTraits = []
        cell.accessibilityValue = nil
        cell.accessibilityHint = nil
    }
}

extension WebDAVConnectionSetupVC {
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .server:
            switch serverRows[indexPath.row] {
            case .url:
                configureURLCell(cell as! TextFieldCell)
            case .allowUntrusted:
                configureAllowUntrustedCell(cell as! SwitchCell)
            }

        case .credentials:
            switch CredentialsRow(rawValue: indexPath.row) {
            case .username:
                configureUsernameCell(cell as! TextFieldCell)
            case .password:
                configurePasswordCell(cell as! ProtectedTextFieldCell)
            case .none:
                break
            }

        case .fullUrl:
            configureFullURLCell(cell)

        case .help:
            configureHelpButtonCell(cell as! ButtonCell)
        }
    }

    private func configureURLCell(_ cell: TextFieldCell) {
        cell.textField.placeholder = config.serverURLPlaceholder
        cell.textField.textContentType = .URL
        cell.textField.isSecureTextEntry = false
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        cell.textField.keyboardType = .URL
        cell.textField.clearButtonMode = .whileEditing
        cell.textField.returnKeyType = .next
        cell.textField.borderWidth = 0

        webdavURLTextField = cell.textField
        webdavURLTextField?.delegate = self
        webdavURLTextField?.validityDelegate = self
        webdavURLTextField?.text = config.serverURL?.absoluteString
    }

    private func configureAllowUntrustedCell(_ cell: SwitchCell) {
        cell.textLabel?.text = LString.titleAllowUntrustedCertificate
        cell.detailTextLabel?.text = nil
        cell.theSwitch.isOn = config.allowUntrusted
        cell.onDidToggleSwitch = { [weak self] theSwitch in
            self?.config.allowUntrusted = theSwitch.isOn
        }
    }

    private func configureUsernameCell(_ cell: TextFieldCell) {
        cell.textField.placeholder = LString.fieldUserName
        cell.textField.textContentType = .username
        cell.textField.isSecureTextEntry = false
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        cell.textField.keyboardType = .emailAddress
        cell.textField.clearButtonMode = .whileEditing
        cell.textField.returnKeyType = .next
        cell.textField.borderWidth = 0

        webdavUsernameTextField = cell.textField
        webdavUsernameTextField?.delegate = self
        webdavUsernameTextField?.validityDelegate = self
        webdavUsernameTextField?.text = config.username
    }

    private func configurePasswordCell(_ cell: TextFieldCell) {
        cell.textField.placeholder = LString.fieldPassword
        cell.textField.textContentType = .password
        cell.textField.isSecureTextEntry = true
        cell.textField.keyboardType = .default
        cell.textField.clearButtonMode = .whileEditing
        cell.textField.returnKeyType = .continue
        cell.textField.borderWidth = 0

        webdavPasswordTextField = cell.textField
        webdavPasswordTextField?.delegate = self
        webdavPasswordTextField?.validityDelegate = self
        webdavPasswordTextField?.text = config.password
    }

    private func configureFullURLCell(_ cell: UITableViewCell) {
        var content = cell.defaultContentConfiguration()
        content.text = config.fullURL?.absoluteString ?? config.serverURLPlaceholder
        content.textProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .none
    }

    private func configureHelpButtonCell(_ cell: ButtonCell) {
        var config = cell.button.configuration ?? UIButton.Configuration.plain()
        config.title = self.config.helpButtonTitle
        config.baseForegroundColor = .actionTint
        cell.button.configuration = config
        cell.accessoryType = .none

        cell.buttonPressHandler = { [weak self] _ in
            self?.didPressHelpButton()
        }
    }

    private func setWebdavInputURL(url: URL?) {
        guard let url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              url.scheme?.isNotEmpty ?? false,
              url.host?.isNotEmpty ?? false,
              let inputURL = urlComponents.url
        else {
            config.serverURL = nil
            refreshDoneButton()
            return
        }

        let inputURLScheme = inputURL.scheme ?? ""
        guard WebDAVFileURL.schemes.contains(inputURLScheme) else {
            config.serverURL = nil
            refreshDoneButton()
            return
        }

        var inputTextNeedsUpdate = false
        if let urlUser = urlComponents.user {
            config.username = urlUser
            webdavUsernameTextField?.text = urlUser
            inputTextNeedsUpdate = true
        }
        if let urlPassword = urlComponents.password {
            config.password = urlPassword
            webdavPasswordTextField?.text = urlPassword
            inputTextNeedsUpdate = true
        }
        urlComponents.user = nil
        urlComponents.password = nil
        config.serverURL = urlComponents.url
        if inputTextNeedsUpdate {
            webdavURLTextField?.text = config.serverURL?.absoluteString ?? url.absoluteString
        }

        refreshDoneButton()
    }
}

extension WebDAVConnectionSetupVC: ValidatingTextFieldDelegate, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case webdavURLTextField:
            webdavUsernameTextField?.becomeFirstResponder()
            return false
        case webdavUsernameTextField:
            webdavPasswordTextField?.becomeFirstResponder()
            return false
        case webdavPasswordTextField:
            didPressDone()
            return false
        default:
            return true
        }
    }

    func validatingTextField(_ sender: ValidatingTextField, textDidChange text: String) {
        switch sender {
        case webdavURLTextField:
            setWebdavInputURL(url: URL(string: text))
            updateFullURLCell()
        case webdavUsernameTextField:
            config.username = text
            refreshDoneButton()
            updateFullURLCell()
        case webdavPasswordTextField:
            config.password = text
            refreshDoneButton()
        default:
            return
        }
    }

    private func updateFullURLCell() {
        guard config.showsFullURLInfo else { return }

        guard let fullURLSectionIndex = sections.firstIndex(of: .fullUrl) else { return }
        let indexPath = IndexPath(row: 0, section: fullURLSectionIndex)

        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
