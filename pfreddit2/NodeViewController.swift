//
//  NodeViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//
//  Controls the view of a single node of content, along with navigation to the next node.

import UIKit

protocol NodeViewControllerDelegate {
	func nodeViewController(nodeViewController: NodeViewController, navigatedToNode node: ContentNode)
}

class NodeViewController: UIViewController {
	let kEdgeFetchCount = 50
	let kNodePreviewCellIdentifier = "NodePreviewCell"

	var nodeViewDelegate: NodeViewControllerDelegate?

	lazy var nodeViewController: ContentNodeViewController! = ContentNodeViewController()
	lazy var edgesViewController: GraphEdgesViewController! = GraphEdgesViewController()

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

	convenience init() {
		self.init(node: nil)
	}

	init(node: ContentNode?) {
		super.init(nibName: nil, bundle: nil)
		if let node = node {
			presentNode(node)
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
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
		navigationItem.title = activeNode?.title
		navigationItem.leftBarButtonItems = nil

		nodeViewController.view.frame = view.frame
		addViewControllerToViewHierarchy(nodeViewController)
	}

	func presentEdgesViewForActiveNode() {
//		edgesViewController.view.frame = view.frame
//		addViewControllerToViewHierarchy(edgesViewController)

		edgesViewController.providesPresentationContextTransitionStyle = true
		edgesViewController.definesPresentationContext = true
		edgesViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
		self.presentViewController(edgesViewController, animated: true, completion: nil)
	}

	private func addViewControllerToViewHierarchy(viewController: UIViewController) {
		addChildViewController(viewController)
		view.addSubview(viewController.view)
		viewController.didMoveToParentViewController(self)
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
			if let thumbnailURLString = self.edgeAtIndexPath(indexPath)?.destination.thumbnailURL,
					let thumbnailURL = NSURL(string: thumbnailURLString) {
					dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
						if let data = NSData(contentsOfURL: thumbnailURL) {
							let image: UIImage? = UIImage(data: data)
							dispatch_async(dispatch_get_main_queue()) {
								cell.thumbnailView.image = image
							}
						}
					}
				}
		}
		return cell
	}
}

extension NodeViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		guard let destinationNode = self.edgeAtIndexPath(indexPath)?.destination else { return }
		nodeViewDelegate?.nodeViewController(self, navigatedToNode: destinationNode)
		self.dismissViewControllerAnimated(true, completion: nil)
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