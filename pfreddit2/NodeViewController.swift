//
//  GraphNavigationViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class NodeViewController: UINavigationController {
	let kEdgeFetchCount = 10
	let kNodePreviewCellIdentifier = "NodePreviewCell"

	var nodeViewController: ContentNodeViewController!
	var edgesViewController: GraphEdgesViewController!

	var activeNode: ContentNode? {
		didSet {
			guard activeNode != oldValue else { return }
			edges = nil
			if let activeNode = activeNode {
				SharedContentGraph.sortedEdgesFromNode(activeNode, count: kEdgeFetchCount).onSuccess {
					self.edges = $0
				}.onFailure { error in
					print("ERROR:", error)
				}
			}
		}
	}
	var edges: [ContentEdge]?

	init() {
		super.init(nibName: nil, bundle: nil)
		nodeViewController = ContentNodeViewController()
		edgesViewController = GraphEdgesViewController()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		nodeViewController = ContentNodeViewController()
		edgesViewController = GraphEdgesViewController()
	}

	override func viewDidLoad() {
		nodeViewController.dataSource = self
		nodeViewController.delegate = self
		edgesViewController.registerNib(UINib(nibName: "NodePreviewCell", bundle: nil), forCellWithReuseIdentifier: kNodePreviewCellIdentifier)
		edgesViewController.collectionDataSource = self
		edgesViewController.collectionDelegate = self
	}

	func presentNode(node: ContentNode) {
		activeNode = node
		print("Presenting", node.id)
		self.pushViewController(nodeViewController, animated: true)
	}

	func presentEdgesViewForActiveNode() {
		self.pushViewController(edgesViewController, animated: true)
	}

	private func edgeAtIndexPath(indexPath: NSIndexPath) -> ContentEdge? {
		return edges?[indexPath.item]
	}
}

extension NodeViewController: UICollectionViewDataSource {
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return edges?.count ?? 0
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kNodePreviewCellIdentifier, forIndexPath: indexPath)
		if let cell = cell as? NodePreviewCell {
			cell.titleLabel.text = self.edgeAtIndexPath(indexPath)?.destination.title
		}
		return cell
	}
}

extension NodeViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		guard let destinationNode = self.edgeAtIndexPath(indexPath)?.destination else { return }
		// TODO: delegate
	}
}

extension NodeViewController: ContentNodeViewDataSource {
	func nodeForContentNodeView(contentViewController: ContentNodeViewController) -> ContentNode? {
		return activeNode
	}
}

extension NodeViewController: ContentNodeViewDelegate {
	func showEdgesForContentNodeView(contentNodeView: ContentNodeViewController) {
		self.presentEdgesViewForActiveNode()
	}
}