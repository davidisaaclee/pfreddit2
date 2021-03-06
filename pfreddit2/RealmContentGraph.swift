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
		print("Initialized RealmContentGraph with database at", realm.path)
	}

	private func edgeFrom(source: ContentNode, toDestination destination: ContentNode) -> Future<RealmContentEdge, ContentGraphError> {
		let edgeQuery = realm.objects(RealmContentEdge).filter("realmSourceNode.id = %@ && realmDestinationNode.id == %@", source.id, destination.id)
		if edgeQuery.count > 1 {
			print("WARNING: Duplicate edges in graph between \(source.id) and \(destination.id)")
		}

		if let edge = edgeQuery.first {
			return Future(value: edge)
		} else {
			let edge = RealmContentEdge()
			edge.realmSourceNode = nodeToRealmNode(source)
			edge.realmDestinationNode = nodeToRealmNode(destination)
			return safeWrite(edge) { edge, realm in
				realm.add(edge)
				try! realm.commitWrite()
			}
		}
	}

	func safeWrite<T>(focusedItem: T, block: (T, Realm) -> Void) -> Future<T, ContentGraphError> {
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

	private func nodeToRealmNode(node: ContentNode) -> RealmContentNode {
		if let node = node as? RealmContentNode {
			return node
		} else if let node = realm.objects(RealmContentNode).filter("id == %@", node.id).first {
			return node
		} else {
			return RealmContentNode(node: node)
		}
	}

	private func queryEdgesFromNode(node: ContentNode) -> Results<RealmContentEdge> {
		return realm.objects(RealmContentEdge).filter("realmSourceNode.id == %@", node.id)
	}
}

extension RealmContentGraph: ContentGraph {
	func nodeForID(id: String) -> Future<ContentNode?, ContentGraphError> {
		return Future(value: realm.objects(RealmContentNode).filter("id == %@", id).first)
	}

	func edgeForID(id: String) -> Future<ContentEdge?, ContentGraphError> {
		return Future(value: realm.objects(RealmContentEdge).filter("id == %@", id).first)
	}

	func nodeWeightingForID(id: String) -> Future<ContentNodeWeighting?, ContentGraphError> {
		return Future(value: realm.objects(RealmContentNodeWeighting).filter("nodeID == %@", id).first)
	}

	func pickNodes(count: Int, filter: NSPredicate? = nil) -> Future<[ContentNode], ContentGraphError> {
		guard count > 0 else { return Future(value: []) }

		var nodesQuery = realm.objects(RealmContentNode)
		if let filter = filter {
			nodesQuery = nodesQuery.filter(filter)
		}
		let generator = nodesQuery.generate()
		var result: [ContentNode] = []
		for _ in 0..<count {
			guard let next = generator.next() else { break }
			result.append(next)
		}
		return Future(value: Array(result))
	}

	func writeNodes(nodes: [ContentNode]) -> Future<[ContentNode], ContentGraphError> {
		let realmNodes = nodes.map(nodeToRealmNode)
		return safeWrite(realmNodes) { nodes, realm in
			nodes.forEach { realm.add($0, update: true) }
		}.map { $0.map { $0 as ContentNode } }
	}

	func incrementWeightOfEdgeFromNode(source: ContentNode, toNode destination: ContentNode, incrementBy weightDelta: EdgeWeight) -> Future<ContentEdge, ContentGraphError> {
		return edgeFrom(source, toDestination: destination).flatMap { edge in
			self.safeWrite(edge) { (var edge, realm) in
				switch weightDelta {
				case .FollowedEdge:
					edge.weightFollowedEdge += 1
				}

				edge.recalculateWeight()
			}
		}
	}

	func incrementWeightOfNode(node: ContentNode, byWeight weightDelta: NodeWeight) -> Future<ContentNodeWeighting, ContentGraphError> {
		return nodeWeightingForID(node.id).flatMap { nodeWeightingOrNil -> Future<ContentNodeWeighting, ContentGraphError> in
			var newNodeWeighting: RealmContentNodeWeighting!
			if nodeWeightingOrNil == nil {
				newNodeWeighting = RealmContentNodeWeighting(node: self.nodeToRealmNode(node))
				self.safeWrite(newNodeWeighting) { weighting, realm in
					realm.add(weighting)
				}
			}

			let nodeWeighting: ContentNodeWeighting = nodeWeightingOrNil ?? newNodeWeighting
			return self.safeWrite(nodeWeighting) { (var nodeWeighting, realm) in
				switch weightDelta {
				case .SeenByActiveUser:
					nodeWeighting.seenByActiveUser = true
				}
				nodeWeighting.recalculateWeight()
			}
		}
	}

	func sortedEdgesFromNode(sourceNode: ContentNode, count: Int = 25) -> Future<[ContentEdge], ContentGraphError> {
		var result: [ContentEdge] = queryEdgesFromNode(sourceNode).sorted("weight").prefix(count).map { $0 as ContentEdge }

		return generateEdgesFromNode(sourceNode, count: count - result.count).map { (generatedEdges: [ContentEdge]) -> [ContentEdge] in
			result.appendContentsOf(generatedEdges)
			return result.sort { (before, after) in before.weight > after.weight }
		}
	}

	// TODO: Filtering here can be much more efficient.
	func generateEdgesFromNode(node: ContentNode, count: Int) -> Future<[ContentEdge], ContentGraphError> {
		if count == 0 {
			return Future(value: [])
		}

		let existingEdgesResults = queryEdgesFromNode(node)
		let nodeWeightsGenerator =
			realm.objects(RealmContentNodeWeighting)
				.filter("nodeID != %@", node.id)
				.sorted("weightAsSourceNode", ascending: false)
				.generate()
		var resultIDs: [String] = []

		func edgePointsToNodeWithID(dstNodeID: String)(edge: ContentEdge) -> Bool {
			return edge.destinationNode.id == dstNodeID
		}

		while resultIDs.count < count, let nextNodeWeight = nodeWeightsGenerator.next() {
			if !existingEdgesResults.contains(edgePointsToNodeWithID(nextNodeWeight.nodeID)) {
				resultIDs.append(nextNodeWeight.nodeID)
			}
		}

		if resultIDs.count < count {
			let nodeGenerator =
				realm.objects(RealmContentNode)
					.filter("id != %@", node.id)
					.generate()

			while resultIDs.count < count, let nextNode = nodeGenerator.next() {
				if !existingEdgesResults.contains(edgePointsToNodeWithID(nextNode.id)) && !resultIDs.contains(nextNode.id) {
					resultIDs.append(nextNode.id)
				}
			}
		}

		let realmSourceNode = nodeToRealmNode(node)
		return resultIDs.map(nodeForID).sequence().map { (seq: [ContentNode?]) -> [ContentEdge] in
			seq
				.filter { $0 != nil }
				.map { RealmContentEdge(sourceNode: realmSourceNode, destinationNode: self.nodeToRealmNode($0!)) }
		}
	}
}