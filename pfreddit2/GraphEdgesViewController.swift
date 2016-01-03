//
//  GraphEdgesViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol GraphEdgesViewControllerDataSource {
	func numberOfEdgesForGraphEdgesViewController(graphEdgesViewController: GraphEdgesViewController) -> Int
	func graphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, viewForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
}

protocol GraphEdgesViewControllerDelegate {
	func graphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, didSelectEdgeAtIndexPath indexPath: NSIndexPath)
}

class GraphEdgesViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView! {
		didSet {
			collectionView.dataSource = self
			collectionView.delegate = self
			collectionView.reloadData()
			_registeredCells.forEach { reuseIdentifier, cellClass in
				collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
			}
			_registeredNibs.forEach { reuseIdentifier, nib in
				collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
			}
		}
	}

	var delegate: GraphEdgesViewControllerDelegate?
	var dataSource: GraphEdgesViewControllerDataSource?

	var contentBackgroundView: UIView!

	private var _registeredCells: [String: AnyClass?] = [:]
	private var _registeredNibs: [String: UINib?] = [:]

	func registerClass(cell: AnyClass?, forCellWithReuseIdentifier reuseIdentifier: String) {
		_registeredCells[reuseIdentifier] = cell
	}

	func registerNib(nib: UINib?, forCellWithReuseIdentifier reuseIdentifier: String) {
		_registeredNibs[reuseIdentifier] = nib
	}

	func dequeueReusableEdgeCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
		return collectionView.dequeueReusableCellWithReuseIdentifier("NodePreviewCell", forIndexPath: indexPath)
	}
}

extension GraphEdgesViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		delegate?.graphEdgesViewController(self, didSelectEdgeAtIndexPath: indexPath)
	}
}

extension GraphEdgesViewController: UICollectionViewDataSource {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let dataSource = dataSource else { return 0 }
		return dataSource.numberOfEdgesForGraphEdgesViewController(self)
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		guard let dataSource = dataSource else {
			return dequeueReusableEdgeCellForIndexPath(indexPath)
		}
		return dataSource.graphEdgesViewController(self, viewForItemAtIndexPath: indexPath)
	}
}