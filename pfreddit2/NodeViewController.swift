//
//  NodeViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//
//  Controls the view of a single node of content, along with navigation to the next node.

import UIKit

protocol NodeViewControllerDelegate: class {
	func nodeViewController(nodeViewController: NodeViewController, wantsToNavigateToNode node: ContentNode)
}

class NodeViewController: UIViewController {
	let kEdgeFetchCount = 20
	
	weak var delegate: NodeViewControllerDelegate?
	var nodeViewDragRecognizer: UIPanGestureRecognizer! {
		didSet {
			nodeViewDragRecognizer.delegate = self
		}
	}


	// MARK: - Child view controllers

	var nodeViewController: ContentNodeViewController! {
		didSet {
			nodeViewController.dataSource = self
		}
	}

	var edgesViewController: GraphEdgesViewController! {
		didSet {
			edgesViewController.dataSource = self
			edgesViewController.delegate = self
		}
	}


	// MARK: - State

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
				edgesViewController?.reloadData()
			}
		}
	}


	// MARK: - Dynamics

	var dynamicsAnimator: UIDynamicAnimator?
	var nodeViewDynamicsBehavior: UIDynamicBehavior!


	// MARK: - UIViewController

	override func viewDidLoad() {
		createNodeViewController()
		createEdgesViewController()
		startDynamics()
	}


	// MARK: - Navigation

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


	// MARK: - Setup helpers

	private func createNodeViewController() {
		nodeViewController = ContentNodeViewController()
		addChildViewController(nodeViewController)
		nodeViewController.view.frame = view.bounds
		view.addSubview(nodeViewController.view)
		nodeViewController.didMoveToParentViewController(self)
	}

	private func createEdgesViewController() {
		edgesViewController = GraphEdgesViewController()
		addChildViewController(edgesViewController)
		edgesViewController.view.frame = view.bounds
		view.insertSubview(edgesViewController.view, belowSubview: nodeViewController.view)
		edgesViewController.didMoveToParentViewController(self)
	}

	private func startDynamics() {
		nodeViewDragRecognizer = UIPanGestureRecognizer(target: self, action: "handleNodeViewDrag:")
		dynamicsAnimator = UIDynamicAnimator(referenceView: view)

		let drawerStart = (from: view.bounds.origin, to: view.bounds.origin + CGPoint(x: view.bounds.width, y: 0))
		let drawerBottomOffset = view.bounds.height * 2 - nodeViewController.infoBar.bounds.height
		let drawerEnd = (from: view.bounds.origin + CGPoint(x: 0, y: drawerBottomOffset), to: view.bounds.origin + CGPoint(x: view.bounds.width, y: drawerBottomOffset))

		nodeViewDynamicsBehavior = SlidingDrawerBehavior(item: nodeViewController.view,
			stops: [
				(boundary: drawerStart, side: .Top),
				(boundary: drawerEnd, side: .Bottom)
			])
		let initialOrigin = nodeViewController.view.frame.origin
		nodeViewDynamicsBehavior.action = {
			let xOffset = self.nodeViewController.view.frame.origin.x - initialOrigin.x
			if xOffset != 0 {
				self.nodeViewController.view.frame = self.nodeViewController.view.frame.offsetBy(dx: -xOffset, dy: 0)
			}
		}

		if let nodeViewDynamicsBehavior = nodeViewDynamicsBehavior as? UIDynamicItemBehavior {
			nodeViewDynamicsBehavior.resistance = 0.4
			nodeViewDynamicsBehavior.elasticity = 0
			nodeViewDynamicsBehavior.allowsRotation = false
			nodeViewDynamicsBehavior.addItem(nodeViewController.view)
		}
		dynamicsAnimator?.addBehavior(nodeViewDynamicsBehavior)
		nodeViewController.view.addGestureRecognizer(nodeViewDragRecognizer)
	}


	// MARK: - Helpers

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
		return edges?[indexPath.row]
	}


	// MARK: - Handlers

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

//	deinit {
//		print("Deinit NodeViewController")
//	}
}


// MARK: - ContentNodeViewDataSource

extension NodeViewController: ContentNodeViewDataSource {
	func nodeForContentNodeView(contentViewController: ContentNodeViewController) -> ContentNode? {
		return activeNode
	}
}


// MARK: - GraphEdgesViewControllerDelegate

extension NodeViewController: GraphEdgesViewControllerDelegate {
	func graphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, didSelectEdgeAtIndexPath indexPath: NSIndexPath) {
		guard let destinationNode = self.edgeAtIndexPath(indexPath)?.destinationNode else { return }
		delegate?.nodeViewController(self, wantsToNavigateToNode: destinationNode)
	}
}


// MARK: - GraphEdgesViewControllerDataSource

extension NodeViewController: GraphEdgesViewControllerDataSource {
	func numberOfEdgesForGraphEdgesViewController(graphEdgesViewController: GraphEdgesViewController) -> Int {
		// TODO: This is being called a lot of times. Is that normal?
		return edges?.count ?? 0
	}

	func graphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, edgeForIndexPath indexPath: NSIndexPath) -> ContentEdge? {
		return self.edgeAtIndexPath(indexPath)
	}
}


// MARK: - UIGestureRecognizerDelegate

extension NodeViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let graphNavigationViewController = navigationController as? GraphNavigationViewController else { return false }

		switch otherGestureRecognizer {
		case graphNavigationViewController.interactiveBackGestureRecognizer:
			return true
		case graphNavigationViewController.interactiveForwardGestureRecognizer:
			return true
		default:
			return false
		}
	}


	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let graphNavigationViewController = navigationController as? GraphNavigationViewController else { return false }

		switch otherGestureRecognizer {
		case graphNavigationViewController.interactiveBackGestureRecognizer:
			return true
		case graphNavigationViewController.interactiveForwardGestureRecognizer:
			return true
		default:
			return false
		}
	}
}