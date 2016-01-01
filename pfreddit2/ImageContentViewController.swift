//
//  ImageContentViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class ImageContentViewController: ContentViewController {

	@IBOutlet var imageView: UIImageView! {
		didSet {
			imageView.contentMode = .ScaleAspectFit

			if let content = contentDataSource?.contentForContentViewController(self) {
				guard case let .Image(url) = content else {
					fatalError("Attempted to display unsupported content on ImageContentViewController.")
				}

				DataRequestor.requestHTTP(url, HTTPAdditionalHeaders: nil).onSuccess { data in
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
}
