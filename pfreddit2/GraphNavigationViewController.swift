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

	override func viewDidLoad() {
		styleNavigationController()
	}

	func pushNodeViewForNode(node: ContentNode) {
		let nodeViewController = NodeViewController(node: node)
		nodeViewController.nodeViewDelegate = self
		pushViewController(nodeViewController, animated: true)
	}

	private func styleNavigationController() {
		navigationBar.barStyle = .Black
		navigationBar.translucent = true

		navigationBar
	}
}

extension GraphNavigationViewController: NodeViewControllerDelegate {
	func nodeViewController(nodeViewController: NodeViewController, navigateToNode node: ContentNode) {
		if let previousNode = nodeViewController.activeNode {
			SharedContentGraph.incrementEdge(previousNode, destination: node, incrementBy: EdgeWeight.FollowedEdge)
				.onFailure { error in print("Failed to increment edge:", error) }
		}
		self.pushNodeViewForNode(node)
	}
}