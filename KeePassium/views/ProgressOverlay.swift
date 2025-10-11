//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
// 
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib
import UIKit

final class ProgressOverlay: UIView {
    typealias CancelActionHandler = (CancelAction) -> Void

    enum CancelAction {
        case cancel
        case useFallback
        case repeatedCancel
    }

    public var title: String? {
        didSet {
            statusLabel.text = title
        }
    }

    public var isCancellable = false {
        didSet {
            updateButtons()
        }
    }

    public var hasFallback = false {
        didSet {
            updateButtons()
        }
    }

    public var isAnimating: Bool {
        get { return spinner.isAnimating }
        set {
            guard newValue != isAnimating else { return }
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
            updateSpinner()
        }
    }

    override public var isOpaque: Bool {
        didSet {
            if isOpaque {
                backgroundColor = .systemGroupedBackground
                panel.backgroundColor = .clear
                panel.layer.shadowRadius = 0
            } else {
                backgroundColor = .systemGroupedBackground.withAlphaComponent(0.5)
                panel.backgroundColor = .systemBackground
                panel.layer.shadowRadius = 40
            }
        }
    }

    public var cancelActionHandler: CancelActionHandler?

    private var cancelPressCounter = 0
    private let cancelCountConsideredUnresponsive = 3

    private var panel: UIView!
    private var spinner: UIActivityIndicatorView!
    private var statusLabel: UILabel!
    private var percentLabel: UILabel!
    private var progressView: UIProgressView!
    private var cancelButton: UIButton!
    private var fallbackButton: UIButton!
    private weak var progress: ProgressEx?

    private var animatingStatusConstraint: NSLayoutConstraint!
    private var staticStatusConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        fatalError("ProgressOverlay.aDecoder not implemented")
    }

    static func addTo(_ parent: UIView, title: String, animated: Bool) -> ProgressOverlay {
        let overlay = ProgressOverlay(frame: parent.bounds)
        overlay.title = title

        if animated {
            overlay.alpha = 0.0
            parent.addSubview(overlay)
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseIn, .allowAnimatedContent],
                animations: {
                    overlay.alpha = 1.0
                },
                completion: nil
            )
        } else {
            parent.addSubview(overlay)
        }
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: parent.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
        ])
        parent.layoutSubviews()

        overlay.accessibilityViewIsModal = true
        UIAccessibility.post(notification: .screenChanged, argument: overlay.statusLabel)

        return overlay
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
        updateSpinner()
        updateButtons()
        isOpaque = true
    }

    func dismiss(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState, .allowAnimatedContent],
                animations: {
                    self.alpha = 0.0
                },
                completion: completion)
        } else {
            self.alpha = 0.0
            completion?(true)
        }
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }

    private func setupViews() {
        backgroundColor = .systemBackground.withAlphaComponent(0.5)

        panel = UIView()
        panel.backgroundColor = .systemBackground
        panel.layer.cornerRadius = 20
        panel.layer.shadowRadius = 40
        panel.layer.shadowOffset = CGSize(width: 0, height: 0)
        panel.layer.shadowOpacity = 0.5
        panel.layer.shadowColor = UIColor.label.cgColor
        addSubview(panel)

        spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = false
        spinner.isHidden = false
        spinner.alpha = 0.0
        spinner.isAccessibilityElement = false
        panel.addSubview(spinner)

        statusLabel = UILabel()
        statusLabel.text = ""
        statusLabel.numberOfLines = 0
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        statusLabel.accessibilityTraits.insert(.updatesFrequently)
        panel.addSubview(statusLabel)

        percentLabel = UILabel()
        percentLabel.text = ""
        percentLabel.numberOfLines = 1
        percentLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        statusLabel.accessibilityTraits.insert(.updatesFrequently)
        panel.addSubview(percentLabel)

        progressView = UIProgressView()
        progressView.progress = 0.0
        progressView.accessibilityTraits.insert(.updatesFrequently)
        panel.addSubview(progressView)

        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.title = LString.actionCancel
        cancelButton = UIButton(configuration: cancelConfig)
        cancelButton.role = .cancel
        cancelButton.addTarget(self, action: #selector(didPressCancel), for: .touchUpInside)
        panel.addSubview(cancelButton)

        var fallbackConfig = UIButton.Configuration.plain()
        fallbackConfig.title = LString.actionUseFallbackDatabase
        fallbackConfig.buttonSize = .small
        fallbackButton = UIButton(configuration: fallbackConfig)
        fallbackButton.addTarget(self, action: #selector(didPressFallback), for: .touchUpInside)
        panel.addSubview(fallbackButton)
    }

    private func setupLayout() {
        panel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        fallbackButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            panel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            panel.centerXAnchor.constraint(equalTo: centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: centerYAnchor),

            progressView.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),

            progressView.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),

            spinner.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
            spinner.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),

            statusLabel.topAnchor.constraint(greaterThanOrEqualTo: panel.topAnchor, constant: 16),
            statusLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -8),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: percentLabel.leadingAnchor, constant: 8),

            percentLabel.bottomAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -8),

            cancelButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),

            fallbackButton.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 8),
            fallbackButton.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            fallbackButton.bottomAnchor.constraint(lessThanOrEqualTo: panel.bottomAnchor, constant: -16),
        ])

        panel.widthAnchor.constraint(equalToConstant: 400.0)
            .setPriority(.defaultHigh)
            .activate()
        staticStatusConstraint = statusLabel.leadingAnchor
            .constraint(equalTo: progressView.leadingAnchor, constant: 8)
            .setPriority(.defaultLow)
            .activate()
        animatingStatusConstraint = statusLabel.leadingAnchor
            .constraint(equalTo: spinner.trailingAnchor, constant: 8.0)
    }

    private func updateSpinner() {
        let isConstraintActive = isAnimating
        let spinnerAlpha: CGFloat = isAnimating ? 1.0 : 0.0

        self.layoutIfNeeded()
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { [weak self] in
                guard let self else { return }
                self.spinner.alpha = spinnerAlpha
                self.animatingStatusConstraint.isActive = isConstraintActive
                self.setNeedsLayout()
                self.layoutIfNeeded()
            },
            completion: nil
        )
    }

    internal func update(with progress: ProgressEx) {
        statusLabel.text = progress.localizedDescription
        percentLabel.text = String(format: "%.0f%%", 100.0 * progress.fractionCompleted)
        progressView.setProgress(Float(progress.fractionCompleted), animated: false)

        isAnimating = progress.isIndeterminate
        self.progress = progress
        updateButtons()
    }

    private func updateButtons() {
        if let progress {
            cancelButton.isEnabled = isCancellable && progress.isCancellable
            fallbackButton.isEnabled = cancelButton.isEnabled && !progress.isCancelled
        } else {
            cancelButton.isEnabled = false
            fallbackButton.isEnabled = false
        }
        fallbackButton.isHidden = !hasFallback
    }

    @objc
    private func didPressCancel(_ sender: UIButton) {
        progress?.cancel()
        cancelPressCounter += 1
        if cancelPressCounter >= cancelCountConsideredUnresponsive {
            cancelActionHandler?(.repeatedCancel)
            cancelPressCounter = 0
        } else {
            cancelActionHandler?(.cancel)
        }
    }

    @objc
    private func didPressFallback(_ sender: UIButton) {
        assert(hasFallback, "Fallback button is supposed to be hidden/disabled")
        progress?.cancel()
        cancelActionHandler?(.useFallback)
    }
}
