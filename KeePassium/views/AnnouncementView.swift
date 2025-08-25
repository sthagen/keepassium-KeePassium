//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import KeePassiumLib

struct AnnouncementItem: Hashable {
    var title: String?
    var body: String?
    var image: UIImage?
    var action: UIAction?
    var onDidPressClose: ((AnnouncementView) -> Void)?

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(body)
        hasher.combine(image)
        hasher.combine(action)
        hasher.combine(onDidPressClose.debugDescription)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.title == rhs.title
            && lhs.body == rhs.body
            && lhs.image == rhs.image
            && lhs.action == rhs.action
            && lhs.onDidPressClose.debugDescription == rhs.onDidPressClose.debugDescription
    }
}

final class AnnouncementView: UIView {
    typealias ActionHandler = (AnnouncementView) -> Void

    private var onDidPressClose: ActionHandler?

    private var title: String?
    private var body: String?
    private var image: UIImage?
    private var action: UIAction?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .symbol(.infoCircle)
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        imageView.tintColor = .label
        imageView.contentMode = .center
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 38).activate()
        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 29).activate()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.borderless()
        config.image = .symbol(.xmark, tint: .secondaryLabel)?
            .applyingSymbolConfiguration(.init(textStyle: .headline, scale: .medium))
        config.imagePadding = .zero
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            guard let self else { return }
            self.onDidPressClose?(self)
        })
        button.accessibilityLabel = LString.actionDismiss
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()

    private lazy var actionButtonSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var actionButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.titleAlignment = .leading
        buttonConfig.titleLineBreakMode = .byWordWrapping
        buttonConfig.buttonSize = .medium
        buttonConfig.imagePadding = 8
        buttonConfig.contentInsets.leading = 0
        buttonConfig.contentInsets.trailing = 0
        let button = UIButton(configuration: buttonConfig)
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    public func apply(_ announcement: AnnouncementItem, backgroundColor: UIColor = .quaternarySystemFill) {
        self.backgroundColor = backgroundColor
        if backgroundColor != .clear {
            layer.cornerRadius = 10
        } else {
            layer.borderWidth = 0
        }
        titleLabel.text = announcement.title
        bodyLabel.text = announcement.body
        imageView.image = announcement.image
        onDidPressClose = announcement.onDidPressClose
        updateActionButton(with: announcement.action)

        setupSubviews()
    }

    private func updateActionButton(with newAction: UIAction?) {
        if let action {
            actionButton.removeAction(action, for: .touchUpInside)
        }
        if let newAction {
            actionButton.addAction(newAction, for: .touchUpInside)
        }
        action = newAction

        var buttonConfig = actionButton.configuration!
        buttonConfig.title = newAction?.title
        buttonConfig.image = newAction?.image
        actionButton.configuration = buttonConfig
    }

    private func setupSubviews() {
        let existingSubviews = subviews
        existingSubviews.forEach {
            $0.removeFromSuperview()
        }

        var topMargin: CGFloat = 4
        var bottomMargin: CGFloat = -4
        let imageTrailingAnchor: NSLayoutXAxisAnchor
        let imageTrailingAnchorConstant: CGFloat
        if let _ = imageView.image {
            addSubview(imageView)
            imageView.topAnchor
                .constraint(equalTo: layoutMarginsGuide.topAnchor, constant: topMargin)
                .activate()
            imageView.leadingAnchor
                .constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 8)
                .activate()
            imageView.bottomAnchor
                .constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor, constant: bottomMargin)
                .setPriority(.defaultHigh)
                .activate()
            imageTrailingAnchor = imageView.trailingAnchor
            imageTrailingAnchorConstant = 16
        } else {
            imageTrailingAnchor = layoutMarginsGuide.leadingAnchor
            imageTrailingAnchorConstant = 8
        }

        var stackedViews = [UIView]()
        var prevViewBottom = layoutMarginsGuide.topAnchor
        if let titleText = titleLabel.text,
           !titleText.isEmpty
        {
            addSubview(titleLabel)
            titleLabel.topAnchor
                .constraint(equalTo: prevViewBottom, constant: topMargin)
                .activate()
            titleLabel.leadingAnchor
                .constraint(equalTo: imageTrailingAnchor, constant: imageTrailingAnchorConstant)
                .activate()
            titleLabel.trailingAnchor
                .constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor, constant: -8)
                .activate()
            stackedViews.append(titleLabel)
            prevViewBottom = titleLabel.lastBaselineAnchor
            topMargin = 8
        }

        if let bodyText = bodyLabel.text,
           !bodyText.isEmpty
        {
            addSubview(bodyLabel)
            bodyLabel.topAnchor
                .constraint(equalTo: prevViewBottom, constant: topMargin)
                .activate()
            bodyLabel.leadingAnchor
                .constraint(equalTo: imageTrailingAnchor, constant: imageTrailingAnchorConstant)
                .activate()
            bodyLabel.trailingAnchor
                .constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor, constant: -8)
                .activate()
            stackedViews.append(bodyLabel)
            prevViewBottom = bodyLabel.bottomAnchor
            topMargin = 8
        }

        if let _ = action {
            addSubview(actionButtonSeparator)
            addSubview(actionButton)
            actionButtonSeparator.heightAnchor.constraint(equalToConstant: 0.25).activate()
            actionButtonSeparator.topAnchor
                .constraint(equalTo: prevViewBottom, constant: 8).activate()
            actionButtonSeparator.leadingAnchor
                .constraint(equalTo: imageTrailingAnchor, constant: imageTrailingAnchorConstant).activate()
            actionButtonSeparator.trailingAnchor
                .constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -8).activate()

            actionButton.layoutMarginsGuide.topAnchor
                .constraint(equalTo: actionButtonSeparator.bottomAnchor, constant: 12)
                .activate()
            actionButton.leadingAnchor
                .constraint(equalTo: imageTrailingAnchor, constant: imageTrailingAnchorConstant)
                .activate()
            actionButton.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: -8)
                .activate()
            actionButton.titleLabel?.numberOfLines = 0
            stackedViews.append(actionButton)
            bottomMargin = 4
        }

        if onDidPressClose != nil {
            addSubview(closeButton)
            closeButton.topAnchor
                .constraint(equalTo: layoutMarginsGuide.topAnchor, constant: -4)
                .activate()
            closeButton.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: -4)
                .activate()

            let closeButtonLeadingAnchor = stackedViews.first?.trailingAnchor ?? imageTrailingAnchor
            closeButton.leadingAnchor
                .constraint(greaterThanOrEqualTo: closeButtonLeadingAnchor, constant: 8)
                .activate()

            closeButton.bottomAnchor
                .constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)
                .activate()
        }
        if let lastStackedView = stackedViews.last {
            lastStackedView.bottomAnchor
                .constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: bottomMargin)
                .setPriority(.required - 1)
                .activate()
        }
    }
}
