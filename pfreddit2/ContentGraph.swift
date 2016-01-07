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

protocol ContentNode {
	var id: String { get }
	var title: String { get }
	var thumbnailURL: String? { get }
	var content: ContentType? { get }
	var metadata: MetadataType? { get }
}

// Describes interactions with a ContentNode which affect associated edge weights.
protocol ContentNodeWeighting {
	var nodeID: String { get }
	var seenByActiveUser: Bool { get set }

	var weightAsSourceNode: Double { get }
	var weightAsDestinationNode: Double { get }

	func recalculateWeight()
}

protocol ContentEdge {
	var id: String { get }
	var sourceNode: ContentNode! { get }
	var destinationNode: ContentNode! { get }
	var weight: Double { get }

	var weightFollowedEdge: Int { get set }

	func recalculateWeight()
}

enum ContentGraphError: ErrorType {
	case DatabaseError(ErrorType)
	case InvalidNode(String)
	case InvalidEdge(String)
}

enum EdgeWeight {
	// Some user has followed an edge which has been presented to them.
	case FollowedEdge
}

enum NodeWeight {
	// The currently active user has seen this node.
	case SeenByActiveUser
}

protocol ContentGraph {
	// Access
	func nodeForID(id: String) -> Future<ContentNode?, ContentGraphError>
	func edgeForID(id: String) -> Future<ContentEdge?, ContentGraphError>
	func nodeWeightingForID(id: String) -> Future<ContentNodeWeighting?, ContentGraphError>
	func pickNodes(count: Int, filter: NSPredicate?) -> Future<[ContentNode], ContentGraphError>

	// Modify
	func writeNode(node: ContentNode) -> Future<ContentNode, ContentGraphError>
	func writeNodes(nodes: [ContentNode]) -> Future<[ContentNode], ContentGraphError>
	func incrementWeightOfEdgeFromNode(source: ContentNode, toNode destination: ContentNode, incrementBy weightDelta: EdgeWeight) -> Future<ContentEdge, ContentGraphError>
	func incrementWeightOfNode(node: ContentNode, byWeight weightDelta: NodeWeight) -> Future<ContentNodeWeighting, ContentGraphError>
	func sortedEdgesFromNode(sourceNode: ContentNode, count: Int) -> Future<[ContentEdge], ContentGraphError>
	func generateEdgesFromNode(node: ContentNode, count: Int) -> Future<[ContentEdge], ContentGraphError>
}

extension ContentGraph {
	func writeNode(node: ContentNode) -> Future<ContentNode, ContentGraphError> {
		return writeNodes([node]).map { $0.first! }
	}
}