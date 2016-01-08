//
//  UIScrollView+setZoomScaleFromPoint.swift
//  pfreddit2
//
//  Created by David Lee on 1/13/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

extension UIScrollView {
	func setZoomScale(zoomScale: CGFloat, fromPoint point: CGPoint, animated: Bool) {
		guard let viewForZooming = delegate?.viewForZoomingInScrollView?(self) else { return }

		let pointToContentOrigin = viewForZooming.bounds.origin - point

		let targetSize = CGSize(width: viewForZooming.bounds.width / zoomScale, height: viewForZooming.bounds.height / zoomScale)
		let targetOrigin = point + (pointToContentOrigin / zoomScale)
		self.zoomToRect(CGRect(origin: targetOrigin, size: targetSize), animated: animated)
	}
}