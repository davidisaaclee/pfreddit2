//
//  TableCollectionViewLayout.swift
//  pfreddit2
//
//  Created by David Lee on 12/26/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol TableCollectionViewLayoutDelegate {
	func tableCollectionViewLayout(layout: TableCollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize?
	func tableCollectionViewLayout(layout: TableCollectionViewLayout, sizeForItemAtIndexPathee: NSIndexPath) -> CGSize?
}

class TableCollectionViewLayout: UICollectionViewLayout {
	var delegate: TableCollectionViewLayoutDelegate?

	var scrollDirection: UICollectionViewScrollDirection = .Vertical
	var itemSize: CGSize {
		guard let collectionViewBounds = collectionView?.bounds else {
			return CGSize(width: 80, height: 80)
		}

		switch scrollDirection {
		case .Vertical:
			return CGSize(width: collectionViewBounds.width, height: 80)
		case .Horizontal:
			return CGSize(width: 80, height: collectionViewBounds.height)
		}
	}

	override func collectionViewContentSize() -> CGSize {
		guard let collectionView = collectionView,
			let dataSource = collectionView.dataSource else { return CGSizeZero }

		let numberOfSections = dataSource.numberOfSectionsInCollectionView?(collectionView) ?? 1
		return (0..<numberOfSections).reduce(CGSizeZero) { acc, sectionIndex in
			let numberOfItemsInSection = dataSource.collectionView(collectionView, numberOfItemsInSection: sectionIndex)
			let sectionSize = (0..<numberOfItemsInSection).reduce(CGSizeZero) { acc, itemIndex in
				let indexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
				let itemSize = self.sizeForItemAtIndexPath(indexPath) ?? CGSizeZero
				return appendLineSize(acc, rhs: itemSize)
			}
			return appendLineSize(acc, rhs: sectionSize)
		}
	}

	override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		// TODO: make faster

		guard let collectionView = collectionView,
			let dataSource = collectionView.dataSource else { return nil }

		var acc: [UICollectionViewLayoutAttributes] = []

		let numberOfSections = dataSource.numberOfSectionsInCollectionView?(collectionView) ?? 1
		(0..<numberOfSections).forEach { sectionIndex in
			let numberOfItemsInSection = dataSource.collectionView(collectionView, numberOfItemsInSection: sectionIndex)
			(0..<numberOfItemsInSection).forEach { itemIndex in
				let indexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
				if let attributes = layoutAttributesForItemAtIndexPath(indexPath) {
					if CGRectIntersectsRect(attributes.frame, rect) {
						acc.append(attributes)
					}
				}
			}
		}

		return acc
	}

	override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
		guard let cellFrame = frameForItemAtIndexPath(indexPath) else {
			fatalError("Unable to calculate frame for valid index path.")
		}
		let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
		attributes.frame = cellFrame
		return attributes
	}

	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
		// TODO
		return true
	}

	// MARK: - Helper methods

	private func frameForItemAtIndexPath(indexPath: NSIndexPath) -> CGRect? {
		guard let origin = originForItemAtIndexPath(indexPath) else { return nil }
		guard let size = sizeForItemAtIndexPath(indexPath) else { return nil }
		return CGRect(origin: origin, size: size)
	}

	private func sizeForItemAtIndexPath(indexPath: NSIndexPath) -> CGSize? {
		// ugh, there's no good way of checking if this delegate method is implemented AND if the implementation returns nil...
		return delegate?.tableCollectionViewLayout(self, sizeForItemAtIndexPath: indexPath) ?? itemSize
	}

	// Returns the combined size of two adjacent items with the provided sizes.
	// For vertical scrolling collection views, the widths are summed; for horizontal views, the heights are summed.
	private func appendItemSize(lhs: CGSize, rhs: CGSize) -> CGSize {
		return appendSizesInDirection(scrollDirection.otherDirection(), lhs: lhs, rhs: rhs)
	}

	private func appendLineSize(lhs: CGSize, rhs: CGSize) -> CGSize {
		return appendSizesInDirection(scrollDirection, lhs: lhs, rhs: rhs)
	}

	private func appendSizesInDirection(direction: UICollectionViewScrollDirection, lhs: CGSize, rhs: CGSize) -> CGSize {
		switch direction {
		case .Horizontal:
			return CGSize(width: lhs.width + rhs.width, height: max(lhs.height, rhs.height))
		case .Vertical:
			return CGSize(width: max(lhs.width, rhs.width), height: lhs.height + rhs.height)
		}
	}

	private func originForItemAtIndexPath(indexPath: NSIndexPath) -> CGPoint? {
		if let previousIndexPath = decrementIndexPath(indexPath) {
			guard let previousOrigin = originForItemAtIndexPath(previousIndexPath),
					let previousItemSize = sizeForItemAtIndexPath(previousIndexPath) else {
				// ?
				return nil
			}
			switch scrollDirection {
			case .Vertical:
				return CGPoint(x: previousOrigin.x, y: previousOrigin.y + previousItemSize.height)
			case .Horizontal:
				return CGPoint(x: previousOrigin.x + previousItemSize.width, y: previousOrigin.y)
			}
		} else {
			return CGPointZero
		}
	}

	// returns `nil` when `indexPath` is head, or when no data source
	private func decrementIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
		guard let collectionView = collectionView,
			let dataSource = collectionView.dataSource else { return nil }

		if indexPath.item > 0 {
			return NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
		} else {
			if indexPath.section > 0 {
				var decrementedSection = indexPath.section - 1
				var numberOfItemsInPreviousSection = dataSource.collectionView(collectionView, numberOfItemsInSection: decrementedSection)

				while numberOfItemsInPreviousSection <= 0 {
					decrementedSection = indexPath.section - 1
					numberOfItemsInPreviousSection = dataSource.collectionView(collectionView, numberOfItemsInSection: decrementedSection)
				}

				return NSIndexPath(forItem: numberOfItemsInPreviousSection - 1, inSection: decrementedSection)
			} else {
				return nil
			}
		}
	}
}

extension UICollectionViewScrollDirection {
	func otherDirection() -> UICollectionViewScrollDirection {
		switch self {
		case .Vertical:
			return .Horizontal
		case .Horizontal:
			return .Vertical
		}
	}
}