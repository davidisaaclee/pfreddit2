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
	@IBOutlet weak var webView: UIWebView! {
		didSet {
			webView.scalesPageToFit = true
		}
	}

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
		switch content {
		case let .Webpage(url):
			print("Loading .Webpage content \(url.absoluteString)...")
			webView.loadRequest(NSURLRequest(URL: url))
		case let .Image(url):
			print("Loading .Image content \(url.absoluteString)...")
			webView.loadRequest(NSURLRequest(URL: url))
		default:
			break
		}
	}

	@IBAction func showEdges() {
		delegate?.showEdgesForContentNodeView(self)
	}
}
