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
	func nodeViewController(nodeViewController: NodeViewController, wantsToNavigateToNode node: ContentNode)
}

class NodeViewController: UIViewController {
	let kEdgeFetchCount = 10
	let kNodePreviewCellIdentifier = "NodePreviewCell"

	var nodeViewDelegate: NodeViewControllerDelegate?

	var nodeViewController: ContentNodeViewController! {
		didSet {
			nodeViewController.dataSource = self
			nodeViewController.delegate = self
		}
	}

	var edgesViewController: GraphEdgesViewController! {
		didSet {
			edgesViewController.registerNib(UINib(nibName: "NodePreviewCell", bundle: nil), forCellWithReuseIdentifier: kNodePreviewCellIdentifier)
			edgesViewController.collectionDataSource = self
			edgesViewController.collectionDelegate = self
			edgesViewController.delegate = self
		}
	}

	var activeNode: ContentNode? {
		didSet {
			edges = nil
			if let activeNode = activeNode {
				reloadEdgesForNode(activeNode)
			}
		}
	}
	var edges: [ContentEdge]? {
		didSet {
			if isViewLoaded() {
				edgesViewController?.collectionView?.reloadData()
			}
		}
	}

	override func viewDidLoad() {
		createNodeViewController()
		createEdgesViewController()
		startDynamics()
	}


	var dynamicsAnimator: UIDynamicAnimator?
//	let nodeViewDynamicsBehavior = UIDynamicItemBehavior()
	var nodeViewDynamicsBehavior: UIDynamicBehavior!
//	let collisionBehavior = UICollisionBehavior()
	lazy var nodeViewDragRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleNodeViewDrag:")

	private func startDynamics() {
		dynamicsAnimator = UIDynamicAnimator(referenceView: view)

		let drawerStart = (from: view.bounds.origin, to: view.bounds.origin + CGPoint(x: view.bounds.width, y: 0))
		let drawerBottomOffset = view.bounds.height * 2 - nodeViewController.infoBar.bounds.height
		let drawerEnd = (from: view.bounds.origin + CGPoint(x: 0, y: drawerBottomOffset), to: view.bounds.origin + CGPoint(x: view.bounds.width, y: drawerBottomOffset))

		nodeViewDynamicsBehavior = SlidingDrawerBehavior(item: nodeViewController.view,
			drawerStart: drawerStart,
			drawerEnd: drawerEnd)

		if let nodeViewDynamicsBehavior = nodeViewDynamicsBehavior as? UIDynamicItemBehavior {
			nodeViewDynamicsBehavior.resistance = 0.4
			nodeViewDynamicsBehavior.elasticity = 0
			nodeViewDynamicsBehavior.allowsRotation = false
			nodeViewDynamicsBehavior.addItem(nodeViewController.view)
		}
		dynamicsAnimator?.addBehavior(nodeViewDynamicsBehavior)
		nodeViewController.view.addGestureRecognizer(nodeViewDragRecognizer)
	}

	private func createNodeViewController() {
		nodeViewController = ContentNodeViewController()
		addChildViewController(nodeViewController)
		nodeViewController.view.frame = view.bounds
		view.addSubview(nodeViewController.view)
		nodeViewController.didMoveToParentViewController(self)
	}

	internal func handleNodeViewDrag(recognizer: UIPanGestureRecognizer) {
		if let nodeViewDynamicsBehavior = nodeViewDynamicsBehavior as? SlidingDrawerBehavior {
			switch recognizer.state {
			case .Began:
				nodeViewDynamicsBehavior.setVelocityZero()

			case .Changed:
				nodeViewController.view.frame = nodeViewController.view.frame.offsetBy(dx: 0, dy: recognizer.translationInView(view).y)
				dynamicsAnimator?.updateItemUsingCurrentState(nodeViewController.view)
				recognizer.setTranslation(CGPointZero, inView: view)

			case .Ended:
				nodeViewDynamicsBehavior.addLinearVelocity(CGPoint(x: 0, y: recognizer.velocityInView(self.view).y), forItem: nodeViewController.view)

			default:
				break
			}
		}
	}

	private func createEdgesViewController() {
		edgesViewController = GraphEdgesViewController()
		addChildViewController(edgesViewController)
		edgesViewController.view.frame = view.bounds
		view.insertSubview(edgesViewController.view, belowSubview: nodeViewController.view)
		edgesViewController.didMoveToParentViewController(self)
	}
	
//	func presentNode(node: ContentNode) {
//		activeNode = node
//		navigationItem.title = activeNode?.title
////		navigationItem.leftBarButtonItems = nil
//
//		nodeViewController.view.frame = view.frame
//		addViewControllerToViewHierarchy(nodeViewController)
//	}

//	func presentEdgesViewForActiveNode() {
//		edgesViewController.view.frame = view.frame
//		presentEdgesViewControllerAnimated(true)
//	}

	func navigateToNode(node: ContentNode) {
		nodeViewDelegate?.nodeViewController(self, wantsToNavigateToNode: node)
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

	private func reloadEdgesForNode(node: ContentNode) {
		SharedContentGraph.sortedEdgesFromNode(node, count: kEdgeFetchCount).onSuccess {
			self.edges = $0
		}.onFailure { error in
			print("ERROR:", error)
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
		print("Edge count:", edges?.count ?? 0)
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
		print("Delete me!")
		nodeViewController.view.frame = nodeViewController.view.frame.offsetBy(dx: 0, dy: 100)
//		self.presentEdgesViewForActiveNode()
	}
}

extension NodeViewController: GraphEdgesViewControllerDelegate {
	func dismissGraphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, animated: Bool) {
		dismissEdgesViewControllerAnimated(true)
	}
}