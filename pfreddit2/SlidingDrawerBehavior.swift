//
//  SlidingDrawerBehavior.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class SlidingDrawerBehavior: UIDynamicBehavior {

	typealias Boundary = (from: CGPoint, to: CGPoint)

	enum BoundarySide {
		case Top, Left, Right, Bottom
	}

	let item: UIDynamicItem
	let stops: [(boundary: Boundary, side: BoundarySide)]

	var itemBehavior: UIDynamicItemBehavior!
	var springBehaviors: [UIFieldBehavior]!
	var collisionBehavior: UICollisionBehavior!
	private var poppedResistanceValue: CGFloat!

	var collisionMargin: CGFloat = 10.0

	init(item: UIDynamicItem, stops: [(boundary: Boundary, side: BoundarySide)]) {
		self.item = item
		self.stops = stops
		super.init()

		itemBehavior = makeDynamicItemBehavior()
		springBehaviors = makeSpringBehaviors()
		collisionBehavior = makeCollisionBehavior()
		setupChildrenBehavior()
	}

	func setVelocityZero() {
		let currentItemVelocity = itemBehavior.linearVelocityForItem(item)
		addLinearVelocity(-currentItemVelocity, forItem: item)
	}

	func addLinearVelocity(velocity: CGPoint, forItem item: UIDynamicItem) {
		itemBehavior.addLinearVelocity(velocity, forItem: item)
	}

	private func setupChildrenBehavior() {
		itemBehavior.addItem(item)
		addChildBehavior(itemBehavior)

		collisionBehavior.addItem(item)
		addChildBehavior(collisionBehavior)

		springBehaviors.forEach { behavior in
			behavior.addItem(self.item)
			addChildBehavior(behavior)
		}
	}

	private func makeDynamicItemBehavior() -> UIDynamicItemBehavior {
		let itemBehavior = UIDynamicItemBehavior()
		itemBehavior.density = 0.03
		itemBehavior.resistance = 4
		itemBehavior.friction = 0.0
		itemBehavior.allowsRotation = false

		return itemBehavior
	}

	private func makeCollisionBehavior() -> UICollisionBehavior {
		let collisionBehavior = UICollisionBehavior()
		collisionBehavior.collisionDelegate = self

		for i in 0..<stops.count {
			let (boundary, side) = stops[i]
			var marginOffset: CGPoint!
			switch side {
			case .Top:
				marginOffset = CGPoint(x: 0, y: -self.collisionMargin)

			case .Bottom:
				marginOffset = CGPoint(x: 0, y: self.collisionMargin)

			default:
				fatalError("Not implemented.")
			}

			collisionBehavior.addBoundaryWithIdentifier("Stop \(i)", fromPoint: boundary.from + marginOffset, toPoint: boundary.to + marginOffset)
		}

		return collisionBehavior
	}

	private func makeSpringBehaviors() -> [UIFieldBehavior] {
		return stops.map { boundary, side in
			let behavior = UIFieldBehavior.springField()
			let (region, position) = self.regionAndPositionFromBoundary(boundary, forItem: self.item, onSide: side)
			behavior.region = region
			behavior.position = position
			behavior.strength = 200.0
			return behavior
		}
	}

	private func regionAndPositionFromBoundary(boundary: (from: CGPoint, to: CGPoint), forItem item: UIDynamicItem, onSide side: BoundarySide) -> (UIRegion, CGPoint) {
		let regionCrossDimension: CGFloat = 60
		let boundaryCenter = ((boundary.to - boundary.from) / 2.0) + boundary.from

		var region: UIRegion!
		var position: CGPoint!

		switch side {
		case .Top, .Bottom:
			region = UIRegion(size: CGSize(width: (boundary.to - boundary.from).length, height: regionCrossDimension))

		default:
			fatalError("Not yet implemented.")
		}

		switch side {
		case .Top:
			position = boundaryCenter + CGPoint(x: 0, y: item.bounds.height / 2.0)

		case .Bottom:
			position = boundaryCenter - CGPoint(x: 0, y: item.bounds.height / 2.0)

		default:
			fatalError("Not yet implemented.")
		}

		return (region, position)
	}
}

extension SlidingDrawerBehavior: UICollisionBehaviorDelegate {
	func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
		let speedThreshold: CGFloat = 100.0
		poppedResistanceValue = itemBehavior.resistance
		let speed = itemBehavior.linearVelocityForItem(item).length
		if speed > speedThreshold {
			itemBehavior.resistance = 150.0 * speed / speedThreshold
		}
	}

	func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
		itemBehavior.resistance = poppedResistanceValue
	}
}