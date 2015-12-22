//
//  ViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/21/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		RedditCommunicator.loadStoriesFromSubreddit("all").onSuccess { listing in
			guard let g = listing.asyncElementGenerator() else {
				print("Couldn't make generator")
				return
			}

			var i = 0
			func successLoop(link: RedditLink) {
				print(link.title)
				if ++i > 50 {
					return
				} else {
					g.next()?.onSuccess(callback: successLoop)
				}
			}

			g.next()?.onSuccess(callback: successLoop)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

