//
//  DirectedWeightedGraph.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation

struct DirectedWeightedEdge<WeightType: Comparable, NodeType: Hashable>: Edge {
	let source: NodeType
	let destination: NodeType
	let weight: WeightType

	var hashValue: Int {
		return composeHashValues(source.hashValue, destination.hashValue)
	}
}
func ==<W: Comparable, N: Hashable>(lhs: DirectedWeightedEdge<W, N>, rhs: DirectedWeightedEdge<W, N>) -> Bool {
	return lhs.source == rhs.source &&
		lhs.destination == rhs.destination &&
		lhs.weight == rhs.weight
}

class DirectedWeightedGraph<WeightType: Comparable, NodeType: Hashable>: NSObject, Graph {
	typealias EdgeType = DirectedWeightedEdge<WeightType, NodeType>

	func edgesFromNode(node: NodeType) -> Set<EdgeType> {
		// TODO
		return []
	}
}
