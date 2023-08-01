//
//  DiffableDataSourceViewModel.swift
//  T-moji
//
//  Created by Homey Poon on 2023-07-31.
//

import UIKit

extension UICollectionViewDiffableDataSource {
    func applySnapshotUsing(sectionIds: [SectionIdentifierType], itemsBySection: [SectionIdentifierType: [ItemIdentifierType]], sectionsRetainedIfEmpty: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        applySnapshotUsing(sectionIds: sectionIds, itemsBySection: itemsBySection, animatingDifferences: true, sectionsRetainedIfEmpty: sectionsRetainedIfEmpty)
    }
    
    func applySnapshotUsing(sectionIds: [SectionIdentifierType], itemsBySection: [SectionIdentifierType: [ItemIdentifierType]], animatingDifferences: Bool, sectionsRetainedIfEmpty: Set<SectionIdentifierType> = Set<SectionIdentifierType>()) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        for sectionId in sectionIds {
            guard let sectionItems = itemsBySection[sectionId],
                  sectionItems.count > 0 || sectionsRetainedIfEmpty.contains(sectionId) else { continue }
            snapshot.appendSections([sectionId])
            snapshot.appendItems(sectionItems, toSection: sectionId)
            snapshot.reloadItems(sectionItems)
        }
        self.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
