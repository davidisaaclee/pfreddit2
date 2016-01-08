//
//  ZoomableItemViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/8/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class ZoomableItemViewController: UIViewController {

	@IBOutlet weak var contentView: UIView! {
		didSet {
			contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		}
	}
	@IBOutlet weak var scrollView: UIScrollView! {
		didSet {
			scrollView.delegate = self
			scrollView.minimumZoomScale = 1.0
			scrollView.maximumZoomScale = 10.0
		}
	}

	var doubleTapZoomResetGestureRecognizer: UITapGestureRecognizer!
	var singleFingerZoomGestureRecognizer: UILongPressGestureRecognizer!

	private var singleFingerZoomGestureRecognizerPreviousPosition: CGPoint!
	private var singleFingerZoomGestureRecognizerInitialPositionInContentView: CGPoint!

	override func viewDidLoad() {
		doubleTapZoomResetGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTapZoomReset:")
		doubleTapZoomResetGestureRecognizer.numberOfTapsRequired = 2

		singleFingerZoomGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleSingleFingerZoom:")
		singleFingerZoomGestureRecognizer.numberOfTapsRequired = 1
		singleFingerZoomGestureRecognizer.minimumPressDuration = 0.1

		scrollView.addGestureRecognizer(doubleTapZoomResetGestureRecognizer)
		scrollView.addGestureRecognizer(singleFingerZoomGestureRecognizer)
	}

	func handleDoubleTapZoomReset(recognizer: UITapGestureRecognizer) {
		if scrollView.zoomScale <= 1.0 {
			scrollView.setZoomScale(5.0, fromPoint: recognizer.locationInView(contentView), animated: true)
		} else {
			scrollView.setZoomScale(1.0, animated: true)
		}
	}

	func handleSingleFingerZoom(recognizer: UILongPressGestureRecognizer) {
		switch recognizer.state {
		case .Began:
			singleFingerZoomGestureRecognizerPreviousPosition = recognizer.locationInView(view)
			singleFingerZoomGestureRecognizerInitialPositionInContentView = recognizer.locationInView(contentView)

		case .Changed:
			let currentPosition = recognizer.locationInView(view)
			let delta = singleFingerZoomGestureRecognizerPreviousPosition - currentPosition
//			print(scrollView.zoomScale * (1 - delta.y / 100.0))
			scrollView.setZoomScale(scrollView.zoomScale * (1 - delta.y / 100.0), fromPoint: singleFingerZoomGestureRecognizerInitialPositionInContentView, animated: false)
			singleFingerZoomGestureRecognizerPreviousPosition = currentPosition

		default:
			break
		}
	}
}


extension ZoomableItemViewController: UIScrollViewDelegate {
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return contentView
	}

	func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// TODO: Nudge `contentView`
	}
}