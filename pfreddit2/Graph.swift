//
//  Graph.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation

protocol Edge: Hashable {
	typealias NodeType: Node

	var source: NodeType { get }
	var destination: NodeType { get }
}

protocol Graph {
	typealias EdgeType: Edge
	typealias NodeType: Hashable

	func edgesFromNode(node: NodeType) -> Set<EdgeType>
}