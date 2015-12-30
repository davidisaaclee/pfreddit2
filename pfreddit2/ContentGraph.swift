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
	var selftext: String? { get }
}

protocol ContentEdge {
	var id: String { get }
	var sourceNode: ContentNode! { get }
	var destinationNode: ContentNode! { get }
	var weight: Double { get }
	var weightFollowedEdge: Int { get set }
}

enum ContentGraphError: ErrorType {
	case DatabaseError(ErrorType)
	case InvalidNode(String)
	case InvalidEdge(String)
}

enum EdgeWeight {
	// User has followed an edge which has been presented to them.
	case FollowedEdge
}

protocol ContentGraph {
//	typealias NodeType: ContentNode
//	typealias EdgeType: ContentEdge
//
//	func nodeForID(id: String) -> Future<NodeType?, ContentGraphError>
//	func edgeForID(id: String) -> Future<EdgeType?, ContentGraphError>
//	// TODO: Is there any way this method can return `Future<Set<ContentNode>, ...>` without assigning type parameters?
//	func pickNodes(count: Int) -> Future<[NodeType], ContentGraphError>
//	func writeNode(node: NodeType) -> Future<NodeType, ContentGraphError>
//	func writeNodes(nodes: [NodeType]) -> Future<[NodeType], ContentGraphError>
//	func incrementEdge(source: NodeType, destination: NodeType, incrementBy weightDelta: EdgeWeight) -> Future<EdgeType, ContentGraphError>
//	func sortedEdgesFromNode(sourceNode: NodeType, count: Int) -> Future<[EdgeType], ContentGraphError>

	func nodeForID(id: String) -> Future<ContentNode?, ContentGraphError>
	func edgeForID(id: String) -> Future<ContentEdge?, ContentGraphError>
	// TODO: Is there any way this method can return `Future<Set<ContentNode>, ...>` without assigning type parameters?
	func pickNodes(count: Int) -> Future<[ContentNode], ContentGraphError>
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