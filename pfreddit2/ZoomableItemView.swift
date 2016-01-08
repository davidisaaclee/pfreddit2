////
////  ZoomableItemView.swift
////  pfreddit2
////
////  Created by David Lee on 1/7/16.
////  Copyright © 2016 David Lee. All rights reserved.
////
//
//import UIKit
//
//class ZoomableItemView: UIScrollView {
//	override var delegate: UIScrollViewDelegate? {
//		set {
//			print("ZoomableItemView must be its own UIScrollView delegate.")
//		}
//		get {
//			return super.delegate
//		}
//	}
//
//	@IBOutlet weak var itemView: UIView? {
//		didSet {
//			if let oldValue = oldValue {
//				oldValue.removeFromSuperview()
//				removeConstraints(itemViewConstraints)
//				itemViewConstraints = []
//			}
//
//			if let itemView = itemView {
//				resetScrollView()
//				itemView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
////				itemView.translatesAutoresizingMaskIntoConstraints = false
////				itemViewConstraints = makeConstraints(itemView)
////				addConstraints(itemViewConstraints)
////				
//			}
//		}
//	}
//
//	var itemViewConstraints: [NSLayoutConstraint] = []
//
//	override required init(frame: CGRect) {
//		super.init(frame: frame)
//		setupSubviews()
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
//		setupSubviews()
//	}
//
//	private func setupSubviews() {
//		super.delegate = self
//		super.minimumZoomScale = 1.0
//		super.maximumZoomScale = 10.0
//		clipsToBounds = true
//	}
//
//	private func resetScrollView() {
//		super.zoomScale = 1.0
//		super.contentOffset = CGPointZero
//	}
//
//	private func makeConstraints(view: UIView) -> [NSLayoutConstraint] {
//		let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|",
//			options: [],
//			metrics: nil,
//			views: ["view": view])
//		let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|",
//			options: [],
//			metrics: nil,
//			views: ["view": view])
//		return [horizontalConstraints, verticalConstraints].flatMap { $0 }
//	}
//}
//
//extension ZoomableItemView: UIScrollViewDelegate {
//	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//		return itemView
//	}
//}