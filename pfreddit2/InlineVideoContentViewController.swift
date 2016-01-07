//
//  InlineVideoContentViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/7/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit
import Player

class InlineVideoContentViewController: ContentViewController {
	override weak var dataSource: ContentViewControllerDataSource? {
		didSet {
			if let content = dataSource?.contentForContentViewController(self) {
				guard case let .InlineVideo(url) = content else {
					fatalError("Attempted to display unsupported content on ImageContentViewController.")
				}

				player = Player()

				guard let player = player else { return }
				player.setUrl(url)
				player.playFromBeginning()
				player.fillMode = "AVLayerVideoGravityResizeAspect"
			}

		}
	}

	var player: Player? {
		didSet {
			guard let player = player else {
				guard let player = oldValue else {
					return
				}

				player.stop()
				player.view.removeFromSuperview()
				player.removeFromParentViewController()
				view.removeConstraints(playerViewConstraints)
				playerViewConstraints = []
				return
			}

			player.view.translatesAutoresizingMaskIntoConstraints = false

			player.view.frame = view.bounds
			addChildViewController(player)
			view.addSubview(player.view)
			player.didMoveToParentViewController(self)
			
			player.playbackLoops = true

			let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[player]-0-|",
				options: [],
				metrics: nil,
				views: ["player": player.view])
			let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[player]-0-|",
				options: [],
				metrics: nil,
				views: ["player": player.view])

			playerViewConstraints = verticalConstraints
			playerViewConstraints.appendContentsOf(horizontalConstraints)
			view.addConstraints(playerViewConstraints)
		}
	}

	private var playerViewConstraints: [NSLayoutConstraint]!

//	func didSetContentDataSource(contentDataSource: ContentViewControllerDataSource?, oldValue: ContentViewControllerDataSource?) {
//		if let content = contentDataSource?.contentForContentViewController(self) {
//			guard case let .InlineVideo(url) = content else {
//				fatalError("Attempted to display unsupported content on ImageContentViewController.")
//			}
//
//			player = Player()
//
//			guard let player = player else { return }
//			player.setUrl(url)
//			player.playFromBeginning()
//			player.fillMode = "AVLayerVideoGravityResizeAspect"
//		}
//	}

	override func viewDidDisappear(animated: Bool) {
		print("Did disappear")
		player = nil
	}

	deinit {
		print("Deinitializing player")
	}
}
