//
//  LinkDetailViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol ContentNodeViewDataSource {
	func nodeForContentNodeView(contentViewController: ContentNodeViewController) -> ContentNode?
}

protocol ContentNodeViewDelegate {
	func showEdgesForContentNodeView(contentNodeView: ContentNodeViewController)
}

class ContentNodeViewController: UIViewController {
	@IBOutlet weak var contentView: UIView!

	var dataSource: ContentNodeViewDataSource? {
		didSet {
			if isViewLoaded() {
				reloadData()
			}
		}
	}

	var delegate: ContentNodeViewDelegate?

	convenience init() {
		self.init(nibName: "ContentNodeViewController", bundle: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		reloadData()
	}

	func reloadData() {
		guard let dataSource = dataSource else { return }
		guard let link = dataSource.nodeForContentNodeView(self) else { return }
		guard let content = link.content else { return }
		guard let contentViewController = createContentViewForContent(content, dataSource: self) else { return }

		addChildViewController(contentViewController)
		contentViewController.view.frame = contentView.bounds
		contentView.addSubview(contentViewController.view)
		contentViewController.didMoveToParentViewController(self)
	}

	@IBAction func showEdges() {
		delegate?.showEdgesForContentNodeView(self)
	}
}

extension ContentNodeViewController: ContentViewControllerDataSource {
	func contentForContentViewController(contentViewController: ContentViewController) -> ContentType? {
		return dataSource?.nodeForContentNodeView(self)?.content
	}
}