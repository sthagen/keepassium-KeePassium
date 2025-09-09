//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import KeePassiumLib

extension DatabaseViewerCoordinator: ProgressViewHost {
    func showProgressView(title: String, allowCancelling: Bool, animated: Bool) {
        if let progressOverlay = _progressOverlay {
            progressOverlay.title = title
            progressOverlay.isCancellable = allowCancelling
            return
        }

        let newOverlay = ProgressOverlay.addTo(
            _splitViewController.view,
            title: title,
            animated: animated)
        newOverlay.isOpaque = false
        newOverlay.isCancellable = allowCancelling
        newOverlay.cancelActionHandler = { [weak self] action in
            switch action {
            case .repeatedCancel:
                self?._showDiagnostics()
            case .cancel, .useFallback:
                break
            }
        }
        self._progressOverlay = newOverlay
    }

    func updateProgressView(with progress: ProgressEx) {
        assert(_progressOverlay != nil)
        _progressOverlay?.update(with: progress)
    }

    func hideProgressView(animated: Bool) {
        _progressOverlay?.dismiss(animated: animated) { [weak self] _ in
            guard let self else { return }
            _progressOverlay?.removeFromSuperview()
            _progressOverlay = nil
        }
    }
}
