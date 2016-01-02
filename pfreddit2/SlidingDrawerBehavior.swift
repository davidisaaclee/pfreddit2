//
//  SlidingDrawerBehavior.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

class SlidingDrawerBehavior: UIDynamicBehavior {
	let item: UIDynamicItem
	let drawerStart: (from: CGPoint, to: CGPoint)
	let drawerEnd: (from: CGPoint, to: CGPoint)

	var itemBehavior: UIDynamicItemBehavior!
	var drawerStartSpringBehavior: UIFieldBehavior!
	var drawerEndSpringBehavior: UIFieldBehavior!
	var collisionBehavior: UICollisionBehavior!

	typealias Boundary = (from: CGPoint, to: CGPoint)

	enum BoundarySide {
		case Top, Left, Right, Bottom
	}

	init(item: UIDynamicItem, drawerStart: (from: CGPoint, to: CGPoint), drawerEnd: (from: CGPoint, to: CGPoint)) {
		self.item = item
		self.drawerStart = drawerStart
		self.drawerEnd = drawerEnd
		super.init()

		itemBehavior = makeDynamicItemBehavior()
		(drawerStartSpringBehavior, drawerEndSpringBehavior) = makeSpringBehaviors()
//		collisionBehavior = makeCollisionBehavior()
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

		drawerStartSpringBehavior.addItem(item)
		addChildBehavior(drawerStartSpringBehavior)

		drawerEndSpringBehavior.addItem(item)
		addChildBehavior(drawerEndSpringBehavior)
	}

	private func makeDynamicItemBehavior() -> UIDynamicItemBehavior {
		let itemBehavior = UIDynamicItemBehavior()
		itemBehavior.density = 0.01
		itemBehavior.resistance = 2
		itemBehavior.friction = 0.0
		itemBehavior.allowsRotation = false

		return itemBehavior
	}

	private func makeCollisionBehavior() -> UICollisionBehavior {
		let collisionBehavior = UICollisionBehavior()
		collisionBehavior.addBoundaryWithIdentifier("DrawerStart", fromPoint: drawerStart.from, toPoint: drawerStart.to)
		collisionBehavior.addBoundaryWithIdentifier("DrawerEnd", fromPoint: drawerEnd.from, toPoint: drawerEnd.to)

		return collisionBehavior
	}

	private func makeSpringBehaviors() -> (UIFieldBehavior!, UIFieldBehavior!) {
		let drawerStartSpringBehavior = UIFieldBehavior.springField()
		let drawerEndSpringBehavior = UIFieldBehavior.springField()

		// TODO: remove hardcoded vertical
		let (startRegion, startPosition) = regionAndPositionFromBoundary(drawerStart, forItem: item, onSide: .Top)
		drawerStartSpringBehavior.region = startRegion
		drawerStartSpringBehavior.position = startPosition
		drawerStartSpringBehavior.strength = 50.0

		let (endRegion, endPosition) = regionAndPositionFromBoundary(drawerEnd, forItem: item, onSide: .Bottom)
		drawerEndSpringBehavior.region = endRegion
		drawerEndSpringBehavior.position = endPosition
		drawerEndSpringBehavior.strength = 50.0

		print(startPosition, endPosition)

		return (drawerStartSpringBehavior, drawerEndSpringBehavior)
	}

	private func regionAndPositionFromBoundary(boundary: (from: CGPoint, to: CGPoint), forItem item: UIDynamicItem, onSide side: BoundarySide) -> (UIRegion, CGPoint) {
		let regionCrossDimension: CGFloat = 30
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