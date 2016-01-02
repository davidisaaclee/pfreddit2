//
//  WebpageContentViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class WebpageContentViewController: ContentViewController {

	@IBOutlet var webView: UIWebView! {
		didSet {
			lockScroll()
			if let content = contentDataSource?.contentForContentViewController(self) {
				guard case let .Webpage(url) = content else {
					fatalError("Attempted to display unsupported content on WebpageContentViewController.")
				}

				webView.loadRequest(NSURLRequest(URL: url))
			}
		}
	}

	@IBAction func scrollLockDidChange(sender: UISwitch) {
		if sender.on {
			unlockScroll()
		} else {
			lockScroll()
		}
	}

	@IBAction func unlockScroll() {
		webView.scrollView.scrollEnabled = true
	}

	@IBAction func lockScroll() {
		webView.scrollView.scrollEnabled = false
	}
}