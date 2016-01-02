//
//  GraphEdgesViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol GraphEdgesViewControllerDelegate {
	func dismissGraphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, animated: Bool)
}

class GraphEdgesViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView? {
		didSet {
			guard let collectionView = collectionView else { return }
			collectionView.dataSource = collectionDataSource
			collectionView.delegate = collectionDelegate
			collectionView.reloadData()
			_registeredCells.forEach { reuseIdentifier, cellClass in
				collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
			}
			_registeredNibs.forEach { reuseIdentifier, nib in
				collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
			}
		}
	}
	var collectionDataSource: UICollectionViewDataSource?
	var collectionDelegate: UICollectionViewDelegate?

	var delegate: GraphEdgesViewControllerDelegate?

	var contentBackgroundView: UIView!

	private var _registeredCells: [String: AnyClass?] = [:]
	private var _registeredNibs: [String: UINib?] = [:]

	override func viewDidLoad() {
		super.viewDidLoad()
//		edgesForExtendedLayout = UIRectEdge.None
		registerDismissRecognizer()
	}

	func registerDismissRecognizer() {
		collectionView?.panGestureRecognizer.addTarget(self, action: "handlePanDismiss:")
	}

	func unregisterDismissRecognizer() {
		collectionView?.panGestureRecognizer.removeTarget(self, action: "handlePanDismiss:")
	}

	func registerClass(cell: AnyClass?, forCellWithReuseIdentifier reuseIdentifier: String) {
		_registeredCells[reuseIdentifier] = cell
	}

	func registerNib(nib: UINib?, forCellWithReuseIdentifier reuseIdentifier: String) {
		_registeredNibs[reuseIdentifier] = nib
	}

	internal func handlePanDismiss(recognizer: UIPanGestureRecognizer) {
		guard let collectionView = collectionView else { return }
		switch recognizer.state {
		case .Ended:
			let threshold: CGFloat = 100
			if collectionView.contentOffset.y < 0 && abs(collectionView.contentOffset.y) > threshold {
				delegate?.dismissGraphEdgesViewController(self, animated: true)
			}

		default:
			break
		}
	}
}