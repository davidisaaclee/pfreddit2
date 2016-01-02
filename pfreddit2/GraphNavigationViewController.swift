//
//  GraphNavigationViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/23/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class GraphNavigationViewController: UINavigationController {
	override func viewDidLoad() {
		styleNavigationController()
	}

	func pushNodeViewForNode(node: ContentNode) {
		let nodeViewController = NodeViewController()
		nodeViewController.activeNode = node
		nodeViewController.nodeViewDelegate = self
		pushViewController(nodeViewController, animated: true)
	}

	private func styleNavigationController() {
		navigationBar.hidden = true
	}
}

extension GraphNavigationViewController: NodeViewControllerDelegate {
	func nodeViewController(nodeViewController: NodeViewController, wantsToNavigateToNode node: ContentNode) {
		if let previousNode = nodeViewController.activeNode {
			SharedContentGraph.incrementEdge(previousNode, destination: node, incrementBy: EdgeWeight.FollowedEdge)
				.onFailure { error in print("Failed to increment edge:", error) }
		}
		self.pushNodeViewForNode(node)
	}
}