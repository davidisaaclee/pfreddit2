//
//  ImageContentViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class ImageContentViewController: ContentViewController {
	override weak var dataSource: ContentViewControllerDataSource? {
		didSet {
			if let content = dataSource?.contentForContentViewController(self) {
				guard case let .Image(url) = content else {
					fatalError("Attempted to display unsupported content on ImageContentViewController.")
				}

				DataRequestor.requestHTTP(url, HTTPAdditionalHeaders: nil).onSuccess { data in
					guard let image = UIImage(data: data) else {
						print("Unable to parse image data as image.")
						return
					}
					self.imageView.image = image
				}.onFailure { error in
					print("Failed to load image.")
				}
			}
		}
	}

	@IBOutlet weak var imageView: UIImageView! {
		didSet {
			imageView.contentMode = .ScaleAspectFit
		}
	}

	var zoomableItemViewController: ZoomableItemViewController!

	override func viewDidLoad() {
		zoomableItemViewController = ZoomableItemViewController()
		addChildViewController(zoomableItemViewController)
		zoomableItemViewController.view.frame = view.bounds
		view.addSubview(zoomableItemViewController.view)
		zoomableItemViewController.didMoveToParentViewController(self)

		imageView.frame = zoomableItemViewController.contentView.bounds
		zoomableItemViewController.contentView.addSubview(imageView)

		imageView.translatesAutoresizingMaskIntoConstraints = false

		let margins = zoomableItemViewController.contentView.layoutMarginsGuide
		imageView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
		imageView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
		imageView.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
		imageView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor).active = true
		zoomableItemViewController.contentView.updateConstraints()
	}

	deinit {
		print("Deinit image view")
	}
}

extension ImageContentViewController: UIScrollViewDelegate {
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return imageView
	}
}