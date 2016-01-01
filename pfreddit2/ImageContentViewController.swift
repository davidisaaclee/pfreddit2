//
//  ImageContentViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class ImageContentViewController: ContentViewController {

	@IBOutlet var webView: UIWebView! {
		didSet {
			if let content = contentDataSource?.contentForContentViewController(self) {
				guard case let .Image(url) = content else {
					fatalError("Attempted to display unsupported content on ImageContentViewController.")
				}

				webView.loadRequest(NSURLRequest(URL: url))
			}
		}
	}
}
