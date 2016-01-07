//
//  LinkDetailViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol ContentNodeViewDataSource: class {
	func nodeForContentNodeView(contentViewController: ContentNodeViewController) -> ContentNode?
}

class ContentNodeViewController: UIViewController {
	@IBOutlet weak var contentView: UIView! {
		didSet { populateContentView() }
	}

	@IBOutlet weak var infoBar: UIView!

	@IBOutlet weak var titleLabel: UILabel! {
		didSet { populateTitleView() }
	}

	@IBOutlet weak var scoreLabel: UILabel? {
		didSet { populateScoreLabel() }
	}

	weak var dataSource: ContentNodeViewDataSource? {
		didSet { reloadData() }
	}

	var node: ContentNode? { return dataSource?.nodeForContentNodeView(self) }
	var content: ContentType? { return node?.content }

	convenience init() {
		self.init(nibName: "ContentNodeViewController", bundle: nil)
	}

	func reloadData() {
		populateContentView()
		populateTitleView()
		populateScoreLabel()
	}

	private func populateContentView() {
		guard let contentView = contentView else { return }
		guard let content = content else { return }
		guard let contentViewController = createContentViewForContent(content) else { return }

		addChildViewController(contentViewController)
		contentViewController.view.frame = contentView.bounds
		contentView.addSubview(contentViewController.view)
		contentViewController.didMoveToParentViewController(self)

		contentViewController.dataSource = self
	}

	private func populateTitleView() {
		guard let titleLabel = titleLabel else { return }
		titleLabel.text = node?.title
	}

	private func populateScoreLabel() {
		guard let scoreLabel = scoreLabel else { return }
		guard let metadata = node?.metadata, case let MetadataType.Reddit(_, score) = metadata else { return }
		scoreLabel.text = score > 0 ? "+\(score)" : "\(score)"
	}

	deinit {
		print("Deinit ContentNodeViewController")
	}
}

extension ContentNodeViewController: ContentViewControllerDataSource {
	func contentForContentViewController(contentViewController: ContentViewController) -> ContentType? {
		return dataSource?.nodeForContentNodeView(self)?.content
	}
}