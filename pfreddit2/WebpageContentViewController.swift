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
			if let content = contentDataSource?.contentForContentViewController(self) {
				guard case let .Webpage(url) = content else {
					fatalError("Attempted to display unsupported content on WebpageContentViewController.")
				}

				webView.loadRequest(NSURLRequest(URL: url))
			}
		}
	}
}