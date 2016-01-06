//
//  SlideAnimatedTransitioning.swift
//  pfreddit2
//
//  Created by David Lee on 1/6/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class SlideAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		guard let containerView = transitionContext.containerView(),
			let fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view,
			let toView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view else {
				return
		}

		let width = containerView.frame.size.width

		var offsetLeft = fromView.frame
		offsetLeft.origin.x = -width / 3.0

		var offscreenRight = toView.frame
		offscreenRight.origin.x = width

		toView.frame = offscreenRight
		containerView.addSubview(toView)

		UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveLinear, animations: {
			toView.frame = fromView.frame
			fromView.frame = offsetLeft
			fromView.layer.opacity = 0.9
		}, completion: { finished in
			fromView.layer.opacity = 1
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
		})
	}

	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.2
	}
}
