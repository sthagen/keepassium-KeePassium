//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator {
    internal func _downloadFavicons(for entries: [Entry], in viewController: UIViewController) {
        downloadFavicons(for: entries, in: viewController) { [weak self] downloadedFavicons in
            guard let self,
                  let downloadedFavicons,
                  let db2 = _database as? Database2
            else {
                return
            }

            downloadedFavicons.forEach {
                guard let entry2 = $0.entry as? Entry2 else {
                    return
                }

                guard let icon = db2.addCustomIcon($0.image) else {
                    Diag.error("Failed to add favicon to database")
                    return
                }
                db2.setCustomIcon(icon, for: entry2)
            }
            refresh()

            let alert = UIAlertController(
                title: _databaseFile.visibleFileName,
                message: String.localizedStringWithFormat(
                    LString.faviconUpdateStatsTemplate,
                    entries.count,
                    downloadedFavicons.count),
                preferredStyle: .alert
            )
            alert.addAction(title: LString.actionSaveDatabase, style: .default, preferred: true) {
                [weak self, weak databaseFile = _databaseFile] _ in
                guard let self, let databaseFile else { return }
                saveDatabase(databaseFile)
            }
            viewController.present(alert, animated: true)
        }
    }

    internal func _downloadFavicons(in viewController: UIViewController? = nil) {
        var allEntries = [Entry]()
        _databaseFile.database.root?.collectAllEntries(to: &allEntries)
        _downloadFavicons(
            for: allEntries,
            in: viewController ?? _presenterForModals)
    }
}

extension DatabaseViewerCoordinator: FaviconDownloading {
    var faviconDownloadingProgressHost: ProgressViewHost? { self }
}
