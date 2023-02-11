//  KeePassium Password Manager
//  Copyright © 2018–2023 Andrei Popleteev <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

protocol DatabaseSettingsDelegate: AnyObject {
    func didPressClose(in viewController: DatabaseSettingsVC)

    func canChangeReadOnly(in viewController: DatabaseSettingsVC) -> Bool
    func didChangeSettings(isReadOnlyFile: Bool, in viewController: DatabaseSettingsVC)

    func didChangeSettings(
        newFallbackStrategy: UnreachableFileFallbackStrategy,
        forAutoFill: Bool,
        in viewController: DatabaseSettingsVC
    )
    func didChangeSettings(
        newFallbackTimeout: TimeInterval,
        forAutoFill: Bool,
        in viewController: DatabaseSettingsVC
    )
}

final class DatabaseSettingsVC: UITableViewController, Refreshable {
    private let fallbackTimeouts: [TimeInterval] = [.zero, 1, 5, 10, 15, 30]
    
    weak var delegate: DatabaseSettingsDelegate?
    
    var isReadOnlyAccess: Bool!
    var fallbackStrategy: UnreachableFileFallbackStrategy!
    var autoFillFallbackStrategy: UnreachableFileFallbackStrategy!
    var availableFallbackStrategies: Set<UnreachableFileFallbackStrategy> = []
    var fallbackTimeout: TimeInterval!
    var autoFillFallbackTimeout: TimeInterval!
    
    private let fallbackTimeoutFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .listItem
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LString.titleDatabaseSettings
        
        registerCellClasses(tableView)
        tableView.alwaysBounceVertical = false
        setupCloseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        tableView.reloadData()
    }
    
    private func setupCloseButton() {
        let closeBarButton = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(
                title: LString.actionDone,
                image: nil,
                attributes: [],
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.delegate?.didPressClose(in: self)
                }
            ),
            menu: nil)
        navigationItem.leftBarButtonItem = closeBarButton
    }
}

extension DatabaseSettingsVC {
    private enum CellID {
        static let switchCell = "SwitchCell"
        static let parameterValueCell = "ParameterValueCell"
    }
    private enum CellIndex {
        static let sectionSizes = [1, 2, 2]
        
        static let readOnly = IndexPath(row: 0, section: 0)
        static let fileUnreachableTimeout = IndexPath(row: 0, section: 1)
        static let fileUnreachableAction = IndexPath(row: 1, section: 1)
        static let autoFillFileUnreachableTimeout = IndexPath(row: 0, section: 2)
        static let autoFillFileUnreachableAction = IndexPath(row: 1, section: 2)
    }
    
    private func registerCellClasses(_ tableView: UITableView) {
        tableView.register(
            SwitchCell.classForCoder(),
            forCellReuseIdentifier: CellID.switchCell)
        tableView.register(
            UINib(nibName: ParameterValueCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: CellID.parameterValueCell)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return CellIndex.sectionSizes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellIndex.sectionSizes[section]
    }
    
    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch section {
        case CellIndex.fileUnreachableAction.section:
            return nil
        case CellIndex.autoFillFileUnreachableAction.section:
            return LString.titleAutoFillSettings
        default:
            return nil
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch indexPath {
        case CellIndex.readOnly:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellID.switchCell,
                for: indexPath)
                as! SwitchCell
            configureReadOnlyCell(cell)
            return cell
        case CellIndex.fileUnreachableTimeout:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellID.parameterValueCell,
                for: indexPath)
                as! ParameterValueCell
            configureFallbackTimeoutCell(cell, timeout: fallbackTimeout, forAutoFill: false)
            return cell
        case CellIndex.fileUnreachableAction:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellID.parameterValueCell,
                for: indexPath)
                as! ParameterValueCell
            configureOfflineAccessCell(cell, strategy: fallbackStrategy, forAutoFill: false)
            return cell
        case CellIndex.autoFillFileUnreachableTimeout:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellID.parameterValueCell,
                for: indexPath)
                as! ParameterValueCell
            configureFallbackTimeoutCell(cell, timeout: autoFillFallbackTimeout, forAutoFill: true)
            return cell
        case CellIndex.autoFillFileUnreachableAction:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellID.parameterValueCell,
                for: indexPath)
                as! ParameterValueCell
            configureOfflineAccessCell(cell, strategy: autoFillFallbackStrategy, forAutoFill: true)
            return cell
        default:
            preconditionFailure("Unexpected cell index")
        }
    }
    
    private func configureReadOnlyCell(_ cell: SwitchCell) {
        cell.textLabel?.text = LString.titleFileAccessReadOnly
        cell.theSwitch.isEnabled = delegate?.canChangeReadOnly(in: self) ?? false
        cell.theSwitch.isOn = isReadOnlyAccess

        cell.textLabel?.isAccessibilityElement = false
        cell.theSwitch.accessibilityLabel = LString.titleFileAccessReadOnly

        cell.onDidToggleSwitch = { [weak self] theSwitch in
            guard let self = self else { return }
            self.isReadOnlyAccess = theSwitch.isOn
            self.delegate?.didChangeSettings(isReadOnlyFile: theSwitch.isOn, in: self)
        }
    }
    
    private func configureOfflineAccessCell(
        _ cell: ParameterValueCell,
        strategy fallbackStrategy: UnreachableFileFallbackStrategy,
        forAutoFill: Bool
    ) {
        cell.textLabel?.text = LString.titleIfFileIsUnreachable
        cell.detailTextLabel?.text = fallbackStrategy.title
        
        let actions = UnreachableFileFallbackStrategy.allCases.map { strategy in
            UIAction(
                title: strategy.title,
                attributes: availableFallbackStrategies.contains(strategy) ? [] : .disabled,
                state: strategy == fallbackStrategy ? .on : .off,
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.delegate?.didChangeSettings(
                        newFallbackStrategy: strategy,
                        forAutoFill: forAutoFill,
                        in: self
                    )
                    self.refresh()
                }
            )
        }
        cell.menu = UIMenu(
            title: LString.titleIfFileIsUnreachable,
            options: .displayInline,
            children: actions
        )
    }
    
    private func configureFallbackTimeoutCell(
        _ cell: ParameterValueCell,
        timeout fallbackTimeout: TimeInterval,
        forAutoFill: Bool
    ) {
        cell.textLabel?.text = LString.titleConsiderFileUnreachable
        cell.detailTextLabel?.text = formatFallbackTimeout(fallbackTimeout)
        
        let actions = fallbackTimeouts.map { timeout -> UIAction in
            let isCurrent = abs(timeout - fallbackTimeout) < .ulpOfOne
            return UIAction(
                title: formatFallbackTimeout(timeout),
                attributes: [],
                state: isCurrent ? .on : .off,
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.delegate?.didChangeSettings(
                        newFallbackTimeout: timeout,
                        forAutoFill: forAutoFill,
                        in: self
                    )
                    self.refresh()
                }
            )
        }
        cell.menu = UIMenu(
            title: LString.titleConsiderFileUnreachable,
            options: .displayInline,
            children: actions
        )
    }
    
    private func formatFallbackTimeout(_ timeout: TimeInterval) -> String {
        if timeout.isZero {
            return LString.appProtectionTimeoutImmediatelyFull 
        }
        return fallbackTimeoutFormatter.localizedString(fromTimeInterval: timeout)
    }
}
