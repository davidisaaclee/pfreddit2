//
//  GraphNavigationViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/23/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class GraphNavigationViewController: UINavigationController {
	// MARK: State
	var nodeTrailIDs: [String] = []
	private var nodeTrailCursor: Int = -1

	// MARK: Gesture recognizers
	var interactiveBackGestureRecognizer: UIScreenEdgePanGestureRecognizer!
	var interactiveForwardGestureRecognizer: UIScreenEdgePanGestureRecognizer!

	// MARK: Transition controllers
	private var animatedTransition: SlideAnimatedTransitioning!
	private var backInteractionController: UIPercentDrivenInteractiveTransition?
	private var forwardInteractionController: UIPercentDrivenInteractiveTransition?


	// MARK: - UIViewController

	override func viewDidLoad() {
		setupInteractiveNavigationControl()
		styleNavigationController()
	}


	// MARK: - Custom navigation

	func pushNodeViewForNode(node: ContentNode, animated: Bool) {
		// Clear trail beyond current node.
		if nodeTrailCursor + 1 < nodeTrailIDs.endIndex {
			nodeTrailIDs.removeRange((nodeTrailCursor + 1)..<nodeTrailIDs.endIndex)
		}

		// Append the new node onto the end of the trail, and navigate to it.
		nodeTrailIDs.append(node.id)
		navigateForwardAnimated(true)
	}

	func navigateForwardAnimated(animated: Bool) {
		animatedTransition.side = .Right
		nodeTrailCursor = nodeTrailCursor + 1
		navigateToCurrentNodeAnimated(animated)
	}

	func navigateBackAnimated(animated: Bool) {
		animatedTransition.side = .Left
		nodeTrailCursor = nodeTrailCursor - 1
		navigateToCurrentNodeAnimated(animated)
	}

	private func navigateToCurrentNodeAnimated(animated: Bool) {
		SharedContentGraph.nodeForID(nodeTrailIDs[nodeTrailCursor]).onSuccess { node in
			guard let node = node else {
				print("Could not find node \(self.nodeTrailIDs[self.nodeTrailCursor]) in database.")
				return
			}

			let nodeViewController = self.createNodeViewControllerForNode(node)
			self.pushViewController(nodeViewController, animated: animated)
			while self.viewControllers.count > 2 {
				let popped = self.viewControllers.removeFirst()
				popped.removeFromParentViewController()
			}
		}.onFailure { error in
			print("Error retrieving node \(self.nodeTrailIDs[self.nodeTrailCursor]):", error)
		}
	}


	// MARK: - Gesture handlers

	internal func handleBackNavigationGesture(recognizer: UIScreenEdgePanGestureRecognizer) {
		let percent = max(recognizer.translationInView(view).x, 0) / view.frame.size.width

		switch recognizer.state {
		case .Began:
			// If we can't go back, just return.
			guard nodeTrailCursor > nodeTrailIDs.startIndex else { return }
			navigateBackAnimated(true)

		case .Changed:
			backInteractionController?.updateInteractiveTransition(percent)

		case .Ended:
			if percent > 0.5 {
				backInteractionController?.finishInteractiveTransition()
			} else {
				navigateForwardAnimated(false)
				backInteractionController?.cancelInteractiveTransition()
			}
		default:
			print(".Unhandled gesture state", recognizer.state)
			break
		}
	}

	internal func handleForwardNavigationGesture(recognizer: UIScreenEdgePanGestureRecognizer) {
		let percent = max(-recognizer.translationInView(view).x, 0) / view.frame.size.width

		switch recognizer.state {
		case .Began:
			// If we can't go back, just return.
			guard nodeTrailCursor < nodeTrailIDs.endIndex - 1 else { return }
			navigateForwardAnimated(true)

		case .Changed:
			forwardInteractionController?.updateInteractiveTransition(percent)

		case .Ended:
			if percent > 0.5 {
				forwardInteractionController?.finishInteractiveTransition()
			} else {
				navigateBackAnimated(false)
				forwardInteractionController?.cancelInteractiveTransition()
			}
		default:
			print(".Unhandled gesture state", recognizer.state)
			break
		}
	}

	
	// MARK: - Initialization helpers

	private func createNodeViewControllerForNode(node: ContentNode) -> NodeViewController {
		let nodeViewController = NodeViewController()
		nodeViewController.delegate = self
		nodeViewController.activeNode = node
		return nodeViewController
	}

	private func styleNavigationController() {
		navigationBar.hidden = true
	}

	private func setupInteractiveNavigationControl() {
		delegate = self
		interactivePopGestureRecognizer?.enabled = false
		animatedTransition = SlideAnimatedTransitioning(side: .Left)

		interactiveBackGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleBackNavigationGesture:")
		interactiveBackGestureRecognizer.edges = .Left

		interactiveForwardGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleForwardNavigationGesture:")
		interactiveForwardGestureRecognizer.edges = .Right

		view.addGestureRecognizer(interactiveBackGestureRecognizer)
		view.addGestureRecognizer(interactiveForwardGestureRecognizer)
	}
}


// MARK: - NodeViewControllerDelegate

extension GraphNavigationViewController: NodeViewControllerDelegate {
	func nodeViewController(nodeViewController: NodeViewController, wantsToNavigateToNode node: ContentNode) {
		if let previousNode = nodeViewController.activeNode {
			SharedContentGraph.incrementEdge(previousNode, destination: node, incrementBy: EdgeWeight.FollowedEdge)
				.onFailure { error in print("Failed to increment edge:", error) }
		}
		self.pushNodeViewForNode(node, animated: true)
	}
}


// MARK: - UINavigationControllerDelegate

extension GraphNavigationViewController: UINavigationControllerDelegate {
	func navigationController(navigationController: UINavigationController,
			animationControllerForOperation operation: UINavigationControllerOperation,
			fromViewController fromVC: UIViewController,
			toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return animatedTransition
	}

	func navigationController(navigationController: UINavigationController,
			interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		switch animatedTransition.side {
		case .Left:
			// Need this switch to return `nil` for non-interactive transitions.
			switch interactiveBackGestureRecognizer.state {
			case .Began:
				backInteractionController = UIPercentDrivenInteractiveTransition()
			default:
				backInteractionController = nil
			}
			return backInteractionController
		case .Right:
			switch interactiveForwardGestureRecognizer.state {
			case .Began:
				forwardInteractionController = UIPercentDrivenInteractiveTransition()
			default:
				forwardInteractionController = nil
			}
			return forwardInteractionController
		}
	}
}