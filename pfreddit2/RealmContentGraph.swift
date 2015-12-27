//
//  RealmContentGraph.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import RealmSwift
import BrightFutures

class RealmContentGraph {
	var realm: Realm!

	init(realm: Realm) {
		self.realm = realm
	}

	private func edgeFrom(source: ContentNode, toDestination destination: ContentNode) -> Future<ContentEdge, ContentGraphError> {
		let edgeQuery = realm.objects(ContentEdge).filter("sourceNode = %@ && destinationNode == %@", source, destination)
		if edgeQuery.count > 1 {
			print("WARNING: Duplicate edges in graph between \(source.id) and \(destination.id)")
		}

		if let edge = edgeQuery.first {
			return Future(value: edge)
		} else {
			let edge = ContentEdge()
			edge.sourceNode = source
			edge.destinationNode = destination
			return safeWrite(edge) { edge, realm in
				realm.add(edge)
				try! realm.commitWrite()
			}
		}
	}

	private func safeWrite<T>(focusedItem: T, block: (T, Realm) -> Void) -> Future<T, ContentGraphError> {
		let promise = Promise<T, ContentGraphError>()

		var notificationToken: NotificationToken!
		notificationToken = realm.addNotificationBlock { (notification, realm) in
			switch notification {
			case .RefreshRequired:
				fatalError("refresh required?")
			default:
				realm.removeNotification(notificationToken)
				promise.success(focusedItem)
			}
		}

		do {
			try realm.write { block(focusedItem, self.realm) }
		} catch let e {
			self.realm.removeNotification(notificationToken)
			promise.failure(.DatabaseError(e))
		}

		return promise.future
	}
}

extension RealmContentGraph: ContentGraph {
	func nodeForID(id: String) -> Future<ContentNode?, ContentGraphError> {
		return Future(value: realm.objects(ContentNode).filter("id == \(id)").first)
	}

	func edgeForID(id: String) -> Future<ContentEdge?, ContentGraphError> {
		return Future(value: realm.objects(ContentEdge).filter("id == \(id)").first)
	}

	func pickNodes(count: Int) -> Future<Set<ContentNode>, ContentGraphError> {
		guard count > 0 else { return Future(value: []) }

		let nodesQuery = realm.objects(ContentNode)
		let generator = nodesQuery.generate()
		var result: Set<ContentNode> = []
		for _ in 0..<count {
			guard let next = generator.next() else { break }
			result.insert(next)
		}
		return Future(value: result)
	}

	func writeNodes(nodes: [ContentNode]) -> Future<[ContentNode], ContentGraphError> {
		return safeWrite(nodes) { nodes, realm in
			nodes.forEach { realm.add($0, update: true) }
		}
	}

	func incrementEdge(source: ContentNode, destination: ContentNode, incrementBy weightDelta: EdgeWeight) -> Future<ContentEdge, ContentGraphError> {
		return edgeFrom(source, toDestination: destination).flatMap { edge in
			self.safeWrite(edge) { edge, realm in
				switch weightDelta {
				case .FollowedEdge:
					edge.weightFollowedEdge += 1
				}
			}
		}
	}

	func sortedEdgesFromNode(sourceNode: ContentNode, count: Int = 25) -> Future<[ContentEdge], ContentGraphError> {
		let edgesQuery = realm.objects(ContentEdge).filter("sourceNode.id == %@", sourceNode.id)
		var result = Array<ContentEdge>(edgesQuery.sorted("weight").prefix(count))
		return pickNodes(count - result.count).map { nodeSet in
			result.appendContentsOf(nodeSet.map { ContentEdge(sourceNode: sourceNode, destinationNode: $0) })
			return result
		}
	}
}