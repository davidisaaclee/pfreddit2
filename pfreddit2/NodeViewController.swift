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
	func nodeViewController(nodeViewController: NodeViewController, navigateToNode node: ContentNode)
}

class NodeViewController: UIViewController {
	let kEdgeFetchCount = 10
	let kNodePreviewCellIdentifier = "NodePreviewCell"

	var nodeViewDelegate: NodeViewControllerDelegate?

	var nodeViewController: ContentNodeViewController! = ContentNodeViewController()
	var edgesViewController: GraphEdgesViewController! = GraphEdgesViewController()

	var activeNode: ContentNode? {
		didSet {
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

	convenience init(node: ContentNode? = nil) {
		self.init(nibName: nil, bundle: nil)
		if let node = node {
			presentNode(node)
		}
	}

	override func viewDidLoad() {
		nodeViewController.dataSource = self
		nodeViewController.delegate = self
		edgesViewController.registerNib(UINib(nibName: "NodePreviewCell", bundle: nil), forCellWithReuseIdentifier: kNodePreviewCellIdentifier)
		edgesViewController.collectionDataSource = self
		edgesViewController.collectionDelegate = self
		edgesViewController.delegate = self
	}
	
	func presentNode(node: ContentNode) {
		activeNode = node
		navigationItem.title = activeNode?.title
		navigationItem.leftBarButtonItems = nil

		nodeViewController.view.frame = view.frame
		addViewControllerToViewHierarchy(nodeViewController)
	}

	func presentEdgesViewForActiveNode() {
		edgesViewController.view.frame = view.frame
		presentEdgesViewControllerAnimated(true)
	}

	func navigateToNode(node: ContentNode) {
		nodeViewDelegate?.nodeViewController(self, navigateToNode: node)
		dismissEdgesViewControllerAnimated(false)
	}

	func presentEdgesViewControllerAnimated(shouldAnimate: Bool) {
		let offscreenOrigin = CGPoint(x: view.frame.origin.x, y: view.frame.origin.y + view.frame.size.height)
		edgesViewController.view.frame = CGRect(origin: offscreenOrigin, size: view.frame.size)
		addViewControllerToViewHierarchy(edgesViewController)

		let animations = {
			self.edgesViewController.view.frame = self.view.frame
		}

		if shouldAnimate {
			let animationOptions: UIViewAnimationOptions = [
				.CurveEaseOut,
				.BeginFromCurrentState
			]
			UIView.animateWithDuration(0.2, delay: 0.0, options: animationOptions,
				animations: animations, completion: nil)
		} else {
			animations()
		}
	}

	func dismissEdgesViewControllerAnimated(shouldAnimate: Bool) {
		let animations = {
			let originʹ = CGPoint(x: self.edgesViewController.view.frame.origin.x, y: self.view.bounds.maxY)
			self.edgesViewController.view.frame = CGRect(origin: originʹ, size: self.edgesViewController.view.frame.size)
		}
		let completion: Bool -> Void = { completed in
			guard completed else { return }
			self.edgesViewController.removeFromParentViewController()
			self.edgesViewController.view.removeFromSuperview()
		}

		if shouldAnimate {
			let animationOptions: UIViewAnimationOptions = [
				.CurveEaseOut,
				.BeginFromCurrentState
			]
			UIView.animateWithDuration(0.2, delay: 0.0, options: animationOptions,
				animations: animations, completion: completion)
		} else {
			animations()
			completion(true)
		}
	}

	private func addViewControllerToViewHierarchy(viewController: UIViewController, parentViewController parentOrNil: UIViewController? = nil) {
		let parentViewController = parentOrNil ?? self
		parentViewController.addChildViewController(viewController)
		parentViewController.view.addSubview(viewController.view)
		viewController.didMoveToParentViewController(parentViewController)
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
			cell.titleLabel.text = self.edgeAtIndexPath(indexPath)?.destinationNode.title
			if let thumbnailURLString = self.edgeAtIndexPath(indexPath)?.destinationNode.thumbnailURL,
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
		guard let destinationNode = self.edgeAtIndexPath(indexPath)?.destinationNode else { return }
		navigateToNode(destinationNode)
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

extension NodeViewController: GraphEdgesViewControllerDelegate {
	func dismissGraphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, animated: Bool) {
		dismissEdgesViewControllerAnimated(true)
	}
}