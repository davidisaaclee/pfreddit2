//
//  SlideAnimatedTransitioning.swift
//  pfreddit2
//
//  Created by David Lee on 1/6/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class SlideAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	enum SlideSide {
		case Left
		case Right
	}

	var side: SlideSide

	required init(side: SlideSide) {
		self.side = side
	}

	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		guard let containerView = transitionContext.containerView(),
			let fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view,
			let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view else {
				return
		}

		let width = containerView.frame.size.width
		let targetFrame = fromView.frame
		let offscreenLeft = targetFrame.offsetBy(dx: width, dy: 0)

		switch side {
		case .Left:
			toView.frame = targetFrame
			containerView.insertSubview(toView, belowSubview: fromView)

			UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveLinear, animations: {
				fromView.frame = offscreenLeft
			}, completion: { finished in
				fromView.layer.opacity = 1
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
			})

		case .Right:
			toView.frame = offscreenLeft
			containerView.insertSubview(toView, aboveSubview: fromView)

			UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveLinear, animations: {
				toView.frame = targetFrame
			}, completion: { finished in
				fromView.layer.opacity = 1
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
			})

		}
	}

	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.35
	}
}
