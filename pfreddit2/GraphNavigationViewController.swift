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
	var nodeTrailCursor: Int = -1 {
		didSet {
			SharedContentGraph.nodeForID(nodeTrailIDs[nodeTrailCursor]).onSuccess { node in
				guard let node = node else {
					print("Could not find node \(self.nodeTrailIDs[self.nodeTrailCursor]) in database.")
					return
				}

				let nodeViewController = self.createNodeViewControllerForNode(node)
				self.pushViewController(nodeViewController, animated: false)
				self.topViewController?.view.addGestureRecognizer(self.interactiveForwardGestureRecognizer)
				self.topViewController?.view.addGestureRecognizer(self.interactiveBackGestureRecognizer)
				while self.viewControllers.count > 2 {
					let popped = self.viewControllers.removeFirst()
					popped.removeFromParentViewController()
				}
			}.onFailure { error in
				print("Error retrieving node \(self.nodeTrailIDs[self.nodeTrailCursor]):", error)
			}
		}
	}

	// MARK: Gesture recognizers
	var interactiveBackGestureRecognizer: UIScreenEdgePanGestureRecognizer!
	var interactiveForwardGestureRecognizer: UIScreenEdgePanGestureRecognizer!

	// MARK: Transition controllers
	private lazy var animatedTransition: UIViewControllerAnimatedTransitioning = SlideAnimatedTransitioning()
	private lazy var percentDrivenTransition: UIPercentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()


	// MARK: - UIViewController

	override func viewDidLoad() {
		interactivePopGestureRecognizer?.enabled = false

		interactiveBackGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleBackNavigationGesture:")
		interactiveBackGestureRecognizer.edges = .Left
		interactiveBackGestureRecognizer.delegate = self

		interactiveForwardGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleForwardNavigationGesture:")
		interactiveForwardGestureRecognizer.edges = .Right
		interactiveForwardGestureRecognizer.delegate = self

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
		nodeTrailCursor = nodeTrailCursor + 1
	}


	// MARK: - Gesture handlers

	internal func handleBackNavigationGesture(recognizer: UIScreenEdgePanGestureRecognizer) {
		// If we can't go back, just return.
		guard nodeTrailCursor > nodeTrailIDs.startIndex else {
			return
		}

		switch recognizer.state {
		case .Ended:
			nodeTrailCursor = nodeTrailCursor - 1
		default:
			break
		}

//		let percent = max(-recognizer.translationInView(view).x, 0) / view.frame.size.width
//		switch recognizer.state {
//		case .Began:
////			popViewControllerAnimated(false)
//			break
//
//		case .Changed:
//			percentDrivenTransition.updateInteractiveTransition(percent)
//
//		case .Ended:
//			if percent > 0.5 {
//				percentDrivenTransition.finishInteractiveTransition()
//			} else {
//				percentDrivenTransition.cancelInteractiveTransition()
//			}
//		case .Cancelled:
//			print("Cancelled")
//		case .Failed:
//			print("Failed")
//		default:
//			break
//		}
	}

	internal func handleForwardNavigationGesture(recognizer: UIScreenEdgePanGestureRecognizer) {
		// If we can't go forward, just return.
		guard nodeTrailCursor < nodeTrailIDs.endIndex - 1 else {
			return
		}

		switch recognizer.state {
		case .Ended:
			nodeTrailCursor = nodeTrailCursor + 1
		default:
			break
		}
	}

	
	// MARK: - Initialization helpers

	private func createNodeViewControllerForNode(node: ContentNode) -> NodeViewController {
		let nodeViewController = NodeViewController()
		nodeViewController.nodeViewDelegate = self
		nodeViewController.activeNode = node
		return nodeViewController
	}

	private func styleNavigationController() {
		navigationBar.hidden = true
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


// MARK: - UIGestureRecognizerDelegate

extension GraphNavigationViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		return true
	}

	// TODO: Maybe make this more specific?
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
			shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
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
		return percentDrivenTransition
	}
}