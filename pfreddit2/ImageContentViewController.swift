//
//  ImageContentViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class ImageContentViewController: ContentViewController {

	@IBOutlet var webView: UIWebView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - ContentView
	override func displayContent(content: ContentType) {
		super.displayContent(content)
		
		guard case let .Image(url) = content else {
			fatalError("Attempted to display unsupported content on WebpageContentViewController.")
		}

		webView.loadRequest(NSURLRequest(URL: url))
	}
}
