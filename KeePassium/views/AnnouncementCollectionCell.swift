//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact us.

import UIKit

final class AnnouncementCollectionCell: UICollectionViewListCell {
    typealias Appearance = UICollectionLayoutListConfiguration.Appearance

    lazy var announcementView: AnnouncementView = {
        let view = AnnouncementView(frame: .zero)
        return view
    }()

    private var topConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!

    static func makeRegistration(appearance: Appearance)
        -> UICollectionView.CellRegistration<AnnouncementCollectionCell, AnnouncementItem>
    {
        UICollectionView.CellRegistration<AnnouncementCollectionCell, AnnouncementItem> {
            cell, indexPath, announcement in
            cell.configure(with: announcement, appearance: appearance)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        contentView.addSubview(announcementView)
        announcementView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = announcementView.topAnchor.constraint(equalTo: contentView.topAnchor)
        bottomConstraint = announcementView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        leadingConstraint = announcementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        trailingConstraint = announcementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            leadingConstraint,
            trailingConstraint
        ])
        separatorLayoutGuide.leadingAnchor.constraint(equalTo: trailingAnchor).activate()
    }

    public func configure(with announcement: AnnouncementItem, appearance: Appearance) {
        var bgConfig = UIBackgroundConfiguration.listPlainCell()
        bgConfig.backgroundInsets = .zero
        bgConfig.backgroundColor = .clear
        topConstraint.constant = 8
        bottomConstraint.constant = -8
        switch appearance {
        case .plain:
            leadingConstraint.constant = 16
            trailingConstraint.constant = -16
        case .insetGrouped:
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
        case .grouped:
            if ProcessInfo.isRunningOnMac {
                leadingConstraint.constant = 0
                trailingConstraint.constant = 0
            } else {
                leadingConstraint.constant = 16
                trailingConstraint.constant = -16
            }
        case .sidebar:
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
        case .sidebarPlain:
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
        @unknown default:
            assertionFailure("Unexpected appearance: \(appearance)")
        }
        self.backgroundConfiguration = bgConfig

        announcementView.apply(announcement)
    }
}
