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
					print("Downloaded image data.")
					guard let image = UIImage(data: data) else {
						print("Unable to parse image data as image.")
						return
					}
					self.imageView.image = image
					self.imageView.sizeToFit()
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

	deinit {
		print("Deinit image view")
	}
}
