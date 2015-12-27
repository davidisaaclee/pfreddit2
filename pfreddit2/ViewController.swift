//
//  ViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/21/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit
import RealmSwift
import BrightFutures

class ViewController: UIViewController {

	lazy var graphNavigationController: GraphNavigationViewController! = GraphNavigationViewController()
	var activeNode: ContentNode?

	override func viewDidLoad() {
		super.viewDidLoad()
		downloadStories(25) {
			SharedContentGraph.pickNodes(1).onSuccess { nodes in
				self.presentViewController(self.graphNavigationController, animated: true) {
					self.graphNavigationController.pushNodeViewForNode(nodes.first!)
				}
			}
		}
	}

	func downloadStories(downloadCount: Int = 25, callback: () -> Void) {
		func readNodePage(alreadyDownloaded: Int)(listing: RedditListing<RedditLink>) {
			if listing.children.count + alreadyDownloaded >= downloadCount {
				let numberToRead = downloadCount - alreadyDownloaded
				let childrenSliceToRead = listing.children.prefix(numberToRead)
				SharedContentGraph.writeNodes(childrenSliceToRead.map(ContentNode.init))
				callback()
				// exit recursion
				return
			} else {
				SharedContentGraph.writeNodes(listing.children.map(ContentNode.init))
				listing.next().onSuccess(callback: readNodePage(alreadyDownloaded + listing.children.count))
			}
		}

		RedditCommunicator.loadStoriesFromSubreddit("all")
			.onSuccess(callback: readNodePage(0))
			.onFailure { print("ERROR:", $0) }
	}

	func makeArbitraryLinks(callback: () -> Void) {
		SharedContentGraph.pickNodes(25).map { nodeSet in
			nodeSet.reduce([]) { (var acc, elm) -> [ContentEdge] in
				if let last = acc.last {
					acc.append(ContentEdge(sourceNode: last.destination, destinationNode: elm))
				} else {
					acc.append(ContentEdge(sourceNode: elm, destinationNode: elm))
				}
				return acc
			}
		}
	}
}