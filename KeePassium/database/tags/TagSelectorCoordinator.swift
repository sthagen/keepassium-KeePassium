//  KeePassium Password Manager
//  Copyright © 2018–2024 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import Foundation
import KeePassiumLib
import UIKit

final class TagSelectorCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var dismissHandler: CoordinatorDismissHandler?

    private let router: NavigationRouter
    private let item: DatabaseItem
    private let parent: DatabaseItem?
    private let tagSelectorVC: TagSelectorVC
    private let database: Database
    private var data: [TagSelectorVC.Section] = []

    var selectedTags: [String] {
        guard let firstSectionTags = data.first?.tags else {
            return []
        }
        let titlesOfSelectedTags = firstSectionTags
            .filter { $0.selected }
            .map { $0.title }
        return titlesOfSelectedTags
    }

    init(item: DatabaseItem, parent: DatabaseItem?, database: Database, router: NavigationRouter) {
        self.item = item
        self.parent = parent
        self.database = database
        self.router = router
        tagSelectorVC = TagSelectorVC.create()
        tagSelectorVC.delegate = self
    }

    deinit {
        assert(childCoordinators.isEmpty)
        removeAllChildCoordinators()
    }

    func start() {
        data = processData()

        router.push(tagSelectorVC, animated: true, onPop: { [weak self] in
            guard let self = self else { return }
            self.removeAllChildCoordinators()
            self.dismissHandler?(self)
        })
    }

    private func processData() -> [TagSelectorVC.Section] {
        let inheritedTags = parent?.resolvingTags() ?? []

        var allEntries = [Entry]()
        var allGroups = [Group]()
        database.root?.collectAllChildren(groups: &allGroups, entries: &allEntries)
        let allTags = allEntries.flatMap({ $0.tags }) + allGroups.flatMap({ $0.tags })

        var tagOccurences = [String: Int]()
        tagOccurences.reserveCapacity(Set(allTags).count)
        allTags.forEach { tag in
            let oldCount = tagOccurences[tag] ?? 0
            tagOccurences[tag] = oldCount + 1
        }
        let tagOccurencesAlphabetically = tagOccurences.sorted {
            $0.key.localizedCompare($1.key) == .orderedAscending
        }
        return [
            .selected(item.tags.map {
                .direct(title: $0, selected: true)
            }),
            .inherited(inheritedTags.map {
                .inherited($0)
            }),
            .all(tagOccurencesAlphabetically.map {
                .database(title: $0.key, selected: item.tags.contains($0.key), occurences: $0.value)
            })
        ]
    }
}

extension TagSelectorCoordinator: TagSelectorVCDelegate {
    func didPressDismiss(in viewController: TagSelectorVC) {
        router.dismiss(animated: true)
    }

    func didToggleTag(_ tag: Tag, in viewController: TagSelectorVC) {
        if case .inherited = tag {
            return
        }

        guard case var .selected(tags) = data.first else {
            return
        }

        if !tags.contains(where: { $0.title == tag.title }) {
            tags.append(.direct(title: tag.title, selected: true))
        } else {
            tags = tags.map {
                if $0.title == tag.title {
                    return .direct(title: tag.title, selected: !tag.selected)
                }
                return $0
            }
        }

        data.remove(at: 0)
        data.insert(.selected(tags), at: 0)

        guard case var .all(tags) = data.last else {
            return
        }

        tags = tags.map {
            if case let .database(title, _, occurences) = $0, title == tag.title {
                return .database(title: title, selected: !tag.selected, occurences: occurences)
            }
            return $0
        }

        data.removeLast()
        data.append(.all(tags))
    }

    func didMoveTag(_ tag: Tag, to row: Int, in viewController: TagSelectorVC) {
        guard var tags = data.first?.tags else {
            return
        }

        tags.removeAll(where: { $0.title == tag.title })
        tags.insert(tag, at: row)

        data[0] = .selected(tags)
    }

    func didPressAddTag(tagText: String?, in viewController: TagSelectorVC) {
        let tags = TagHelper.stringToTags(tagText)
        tags.forEach { [self] tag in
            self.didToggleTag(.direct(title: tag, selected: false), in: viewController)
        }
    }

    func isTagTextValid(_ tagText: String?, in viewController: TagSelectorVC) -> Bool {
        let tags = TagHelper.stringToTags(tagText)
        return !tags.isEmpty
    }

    func getSections(for viewController: TagSelectorVC) -> [TagSelectorVC.Section] {
        return data
    }
}
