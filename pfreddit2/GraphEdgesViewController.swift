//
//  GraphEdgesViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit
import SBTableLayout

class GraphEdgesViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!
	var collectionDataSource: UICollectionViewDataSource?
	var collectionDelegate: UICollectionViewDelegate?

	private var _registeredCells: [String: AnyClass?] = [:]
	private var _registeredNibs: [String: UINib?] = [:]

	func registerClass(cell: AnyClass?, forCellWithReuseIdentifier reuseIdentifier: String) {
		_registeredCells[reuseIdentifier] = cell
	}

	func registerNib(nib: UINib?, forCellWithReuseIdentifier reuseIdentifier: String) {
		_registeredNibs[reuseIdentifier] = nib
	}

	override func viewDidLoad() {
		super.viewDidLoad()

//		let tableLayout = SBCollectionViewTableLayout()
//		collectionView.setCollectionViewLayout(tableLayout, animated: false)

//		if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//			layout.minimumInteritemSpacing = 9999.0
//		}

//		if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//			let xInsets = collectionView.contentInset.left
//									+ collectionView.contentInset.right
//									+ layout.sectionInset.left
//									+ layout.sectionInset.right
//			layout.estimatedItemSize = CGSize(width: collectionView.frame.width - xInsets - 1, height: 100.0)
//		}

		collectionView.dataSource = collectionDataSource
		collectionView.delegate = collectionDelegate
		_registeredCells.forEach { reuseIdentifier, cellClass in
			self.collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
		}

		_registeredNibs.forEach { reuseIdentifier, nib in
			self.collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}