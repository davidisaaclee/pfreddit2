//
//  LinkDetailViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol ContentNodeViewDataSource {
	func nodeForContentNodeView(contentViewController: ContentNodeViewController) -> RedditLink
}

class ContentNodeViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var webView: UIWebView!

	var dataSource: ContentNodeViewDataSource? {
		didSet {
			if isViewLoaded() {
				reloadData()
			}
		}
	}

	convenience init() {
		self.init(nibName: "ContentNodeViewController", bundle: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		reloadData()
	}

	func reloadData() {
		guard let dataSource = dataSource else { return }

		let link = dataSource.nodeForContentNodeView(self)

		titleLabel.text = link.title
		if let url = NSURL(string: link.url) {
			webView.loadRequest(NSURLRequest(URL: url))
		}
	}
}
