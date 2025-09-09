//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {

    internal func _confirmAndExportDatabaseToCSV() {
        let alert = UIAlertController.make(
            title: LString.titleFileExport,
            message: LString.titlePlainTextDatabaseExport,
            dismissButtonTitle: LString.actionCancel
        )
        alert.addAction(title: LString.actionContinue, style: .default, preferred: true) { [weak self] _ in
            self?.exportDatabaseToCSV()
        }
        _presenterForModals.present(alert, animated: true, completion: nil)
    }

    private func exportDatabaseToCSV() {
        guard let root = _database.root else {
            Diag.error("Failed to export database, there is no root group")
            return
        }

        let csvFileName = _databaseFile.fileURL
            .deletingPathExtension()
            .appendingPathExtension("csv")
            .lastPathComponent
        let exporter = DatabaseCSVExporter()
        let csv = exporter.export(root: root)
        let exportHelper = FileExportHelper(data: ByteArray(utf8String: csv), fileName: csvFileName)
        exportHelper.handler = { [weak self] _ in
            self?.fileExportHelper = nil
        }
        exportHelper.saveAs(presenter: _presenterForModals)
        self.fileExportHelper = exportHelper
    }
}
