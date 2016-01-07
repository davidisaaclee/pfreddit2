//
//  GraphEdgesViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol GraphEdgesViewControllerDataSource: class {
	func numberOfEdgesForGraphEdgesViewController(graphEdgesViewController: GraphEdgesViewController) -> Int
	func graphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, edgeForIndexPath indexPath: NSIndexPath) -> ContentEdge?
}

protocol GraphEdgesViewControllerDelegate: class {
	func graphEdgesViewController(graphEdgesViewController: GraphEdgesViewController, didSelectEdgeAtIndexPath indexPath: NSIndexPath)
}

class GraphEdgesViewController: UIViewController {
	static let NodePreviewCellIdentifier = "NodePreviewCell"

	@IBOutlet weak var tableView: UITableView! {
		didSet {
			tableView.registerNib(UINib(nibName: "NodePreviewCell", bundle: nil), forCellReuseIdentifier: GraphEdgesViewController.NodePreviewCellIdentifier)
			tableView.dataSource = self
			tableView.delegate = self
			tableView.rowHeight = UITableViewAutomaticDimension
			tableView.estimatedRowHeight = 96
			reloadData()
		}
	}

	weak var delegate: GraphEdgesViewControllerDelegate?
	weak var dataSource: GraphEdgesViewControllerDataSource?

	private typealias CellData = (text: String?, image: UIImage?, weight: Double?)

	private var cellData: [Int: CellData] = [:] {
		didSet {
			tableView.reloadData()
		}
	}

	func reloadData() {
		guard let dataSource = dataSource else { return }
		let numberOfEdges = dataSource.numberOfEdgesForGraphEdgesViewController(self)

		for edgeIndex in 0..<numberOfEdges {
			let edge = dataSource.graphEdgesViewController(self, edgeForIndexPath: NSIndexPath(forRow: edgeIndex, inSection: 0))
			cellData[edgeIndex] = (text: edge?.destinationNode.title, image: nil, weight: edge?.weight)
			if let thumbnailURLString = edge?.destinationNode.thumbnailURL,
				let thumbnailURL = NSURL(string: thumbnailURLString) {
					dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
						if let data = NSData(contentsOfURL: thumbnailURL) {
							let image: UIImage? = UIImage(data: data)
							dispatch_async(dispatch_get_main_queue()) {
								self.cellData[edgeIndex]!.image = image
							}
						}
					}
			}
		}
	}

	func dequeueReusableEdgeCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCellWithIdentifier("NodePreviewCell") else {
			fatalError("Could not dequeue reusable table view cell.")
		}
		return cell
	}
}


// MARK: - UICollectionViewDelegate

extension GraphEdgesViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		delegate?.graphEdgesViewController(self, didSelectEdgeAtIndexPath: indexPath)
	}
}


// MARK: - UICollectionViewDataSource

extension GraphEdgesViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let dataSource = dataSource else { return 0 }
		return dataSource.numberOfEdgesForGraphEdgesViewController(self)
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let cell = dequeueReusableEdgeCellForIndexPath(indexPath) as? NodePreviewCell else {
			fatalError("Invalid cell type.")
		}
		guard let cellData = cellData[indexPath.row] else { return cell }
		cell.titleLabel.text = cellData.text
		cell.thumbnailView.image = cellData.image
		if let weight = cellData.weight {
			cell.scoreLabel.text = ((weight > 0) ? "+" : "") + "\(Int(floor(weight)))"
		}
		return cell
	}
}