//
//  ContentGraph.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import RealmSwift
import BrightFutures

class ContentNode: Object {
	dynamic var id: String = ""
	dynamic var title: String = ""
	dynamic var thumbnailURL: String?
	dynamic var linkURL: String?
	dynamic var selftext: String?

	override static func primaryKey() -> String? {
		return "id"
	}
}

extension ContentNode: Hashable {}
func ==(lhs: ContentNode, rhs: ContentNode) -> Bool {
	return lhs.id == rhs.id
}

class ContentEdge: Object {
	dynamic var id: String = ""
	dynamic var sourceNode: ContentNode! = nil { didSet { updateID() } }
	dynamic var destinationNode: ContentNode! = nil { didSet { updateID() } }
	dynamic var weight: Double = 0.0
	dynamic var weightFollowedEdge: Int = 0 { didSet { recalculateWeight() } }

	override var description: String {
		return "\(id) (\(weight))"
	}

	convenience init(sourceNode: ContentNode, destinationNode: ContentNode) {
		self.init()
		self.sourceNode = sourceNode
		self.destinationNode = destinationNode
	}

	override static func primaryKey() -> String? {
		return "id"
	}

	func recalculateWeight() {
		self.weight = Double(weightFollowedEdge)
	}

	private func updateID() {
		guard sourceNode != nil && destinationNode != nil else { return }
		self.id = "(\(sourceNode.id) -> \(destinationNode.id))"
	}
}

extension ContentEdge: Edge {
	var source: ContentNode {
		return sourceNode
	}
	var destination: ContentNode {
		return destinationNode
	}
}
func ==(lhs: ContentEdge, rhs: ContentEdge) -> Bool {
	return false
}


enum ContentGraphError: ErrorType {
	case DatabaseError(ErrorType)
}

enum EdgeWeight {
	// When a user has followed an edge which has been presented to them.
	case FollowedEdge
}

protocol ContentGraph {
	func nodeForID(id: String) -> Future<ContentNode?, ContentGraphError>
	func edgeForID(id: String) -> Future<ContentEdge?, ContentGraphError>
	func pickNodes(count: Int) -> Future<Set<ContentNode>, ContentGraphError>
	func writeNode(node: ContentNode) -> Future<ContentNode, ContentGraphError>
	func writeNodes(nodes: [ContentNode]) -> Future<[ContentNode], ContentGraphError>
	func incrementEdge(source: ContentNode, destination: ContentNode, incrementBy weightDelta: EdgeWeight) -> Future<ContentEdge, ContentGraphError>
	func sortedEdgesFromNode(sourceNode: ContentNode, count: Int) -> Future<[ContentEdge], ContentGraphError>
}

extension ContentGraph {
	func writeNode(node: ContentNode) -> Future<ContentNode, ContentGraphError> {
		return writeNodes([node]).map { $0.first! }
	}
}