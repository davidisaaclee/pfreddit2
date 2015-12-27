//
//  GraphNavigationViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/23/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class GraphNavigationViewController: UINavigationController {
	let kNavigationEdgeWeight = 1.0

	var nodeViewControllers: [NodeViewController] = []

//	override func viewDidLoad() {
//	}

	func pushNodeViewForNode(node: ContentNode) {
		let nodeViewController = NodeViewController(node: node)
		nodeViewController.nodeViewDelegate = self
		self.pushViewController(nodeViewController, animated: true)
		nodeViewControllers.append(nodeViewController)
	}
}

extension GraphNavigationViewController: NodeViewControllerDelegate {
	func nodeViewController(nodeViewController: NodeViewController, navigatedToNode node: ContentNode) {
		if let previousNode = nodeViewController.activeNode {
			SharedContentGraph.incrementEdge(previousNode, destination: node, incrementBy: EdgeWeight.FollowedEdge)
//				.onSuccess { edge in print("Incremented edge:", edge) }
//				.onFailure { error in print("Failed to increment edge:", error) }
		}
		self.pushNodeViewForNode(node)
	}
}