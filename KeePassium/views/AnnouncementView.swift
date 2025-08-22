//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import UIKit

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
        hasher.combine(action.debugDescription)
        hasher.combine(onDidPressClose.debugDescription)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.title == rhs.title
            && lhs.body == rhs.body
            && lhs.image == rhs.image
            && lhs.action.debugDescription == rhs.action.debugDescription
            && lhs.onDidPressClose.debugDescription == rhs.onDidPressClose.debugDescription
    }
}

final class AnnouncementView: UIView {
    typealias ActionHandler = (AnnouncementView) -> Void

    var onDidPressClose: ActionHandler? {
        didSet {
            setupSubviews()
        }
    }

    var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
            setupSubviews()
        }
    }
    var body: String? {
        get { bodyLabel.text }
        set {
            bodyLabel.text = newValue
            setupSubviews()
        }
    }
    var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            setupSubviews()
        }
    }

    var action: UIAction? {
        didSet {
            var buttonConfig = UIButton.Configuration.plain()
            buttonConfig.title = action?.title
            buttonConfig.image = action?.image
            buttonConfig.titleAlignment = .leading
            buttonConfig.titleLineBreakMode = .byWordWrapping
            buttonConfig.buttonSize = .medium
            buttonConfig.imagePadding = 8
            buttonConfig.contentInsets.leading = 0
            buttonConfig.contentInsets.trailing = 0
            actionButton.configuration = buttonConfig
            setupSubviews()
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .symbol(.infoCircle)
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body, scale: .large)
        imageView.tintColor = .label
        imageView.contentMode = .center
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 36).activate()
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
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .close, primaryAction: UIAction {[weak self] _ in
            guard let self else { return }
            self.onDidPressClose?(self)
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(primaryAction: action)
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .quaternarySystemFill
        layer.cornerRadius = 10
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 1

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    public func apply(_ announcement: AnnouncementItem) {
        title = announcement.title
        body = announcement.body
        image = announcement.image
        action = announcement.action
        onDidPressClose = announcement.onDidPressClose
        layoutSubviews()
    }

    private func setupSubviews() {
        let existingSubviews = subviews
        existingSubviews.forEach {
            $0.removeFromSuperview()
        }

        let hasImage = image != nil
        let hasTitle = !(title?.isEmpty ?? true)
        let hasBody = !(body?.isEmpty ?? true)
        let hasButton = action != nil
        let canBeClosed = onDidPressClose != nil

        var stackedViews = [UIView]()

        let imageTrailingAnchor: NSLayoutXAxisAnchor
        let imageTrailingAnchorConstant: CGFloat
        if hasImage {
            addSubview(imageView)
            imageView.leadingAnchor
                .constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 4)
                .activate()
            imageView.topAnchor
                .constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor)
                .activate()
            imageView.centerYAnchor
                .constraint(equalTo: layoutMarginsGuide.centerYAnchor)
                .setPriority(.defaultHigh)
                .activate()
            imageTrailingAnchor = imageView.trailingAnchor
            imageTrailingAnchorConstant = 8
        } else {
            imageTrailingAnchor = layoutMarginsGuide.leadingAnchor
            imageTrailingAnchorConstant = 8
        }

        let titleBottomAnchor: NSLayoutYAxisAnchor
        let titleBottomAnchorConstant: CGFloat
        if hasTitle {
            addSubview(titleLabel)
            stackedViews.append(titleLabel)
            titleLabel.topAnchor
                .constraint(equalTo: layoutMarginsGuide.topAnchor)
                .activate()
            titleLabel.leadingAnchor
                .constraint(equalTo: imageTrailingAnchor, constant: imageTrailingAnchorConstant)
                .activate()
            titleLabel.trailingAnchor
                .constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor, constant: -8)
                .activate()
            titleBottomAnchor = titleLabel.bottomAnchor
            titleBottomAnchorConstant = 8
        } else {
            titleBottomAnchor = layoutMarginsGuide.topAnchor
            titleBottomAnchorConstant = 0
        }

        let bodyBottomAnchor: NSLayoutYAxisAnchor
        let bodyBottomAnchorConstant: CGFloat
        if hasBody {
            addSubview(bodyLabel)
            stackedViews.append(bodyLabel)
            bodyLabel.topAnchor
                .constraint(equalTo: titleBottomAnchor, constant: titleBottomAnchorConstant)
                .activate()
            bodyLabel.leadingAnchor
                .constraint(equalTo: imageTrailingAnchor, constant: imageTrailingAnchorConstant)
                .activate()
            bodyLabel.trailingAnchor
                .constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor, constant: -8)
                .activate()
            bodyBottomAnchor = bodyLabel.bottomAnchor
            bodyBottomAnchorConstant = 8
        } else {
            bodyBottomAnchor = titleBottomAnchor
            bodyBottomAnchorConstant = 0
        }

        if hasButton {
            addSubview(actionButton)
            stackedViews.append(actionButton)
            actionButton.topAnchor
                .constraint(equalTo: bodyBottomAnchor, constant: bodyBottomAnchorConstant)
                .activate()
            actionButton.leadingAnchor
                .constraint(equalTo: imageTrailingAnchor, constant: imageTrailingAnchorConstant)
                .activate()
            actionButton.trailingAnchor
                .constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -8)
                .activate()
            actionButton.titleLabel?.numberOfLines = 0
        }

        if canBeClosed {
            addSubview(closeButton)
            closeButton.topAnchor
                .constraint(equalTo: layoutMarginsGuide.topAnchor)
                .activate()
            closeButton.trailingAnchor
                .constraint(equalTo: layoutMarginsGuide.trailingAnchor)
                .activate()

            let closeButtonLeadingAnchor = stackedViews.first?.trailingAnchor ?? imageTrailingAnchor
            closeButton.leadingAnchor
                .constraint(equalTo: closeButtonLeadingAnchor, constant: 8)
                .activate()

            let closeButtonBottomGuide: NSLayoutYAxisAnchor
            if stackedViews.count > 1 {
                closeButtonBottomGuide = stackedViews[1].topAnchor
            } else {
                closeButtonBottomGuide = layoutMarginsGuide.bottomAnchor
            }
            closeButton.bottomAnchor
                .constraint(lessThanOrEqualTo: closeButtonBottomGuide)
                .activate()
        }
        stackedViews.last?.bottomAnchor
            .constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            .activate()
    }
}
