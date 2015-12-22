//
//  GraphNavigationViewController.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

protocol GraphNavigationViewDataSource {
	func edgesFromNode<NodeType: Hashable, EdgeType: Edge>(node: NodeType) -> Set<EdgeType>
	func pickNode<NodeType: Hashable>() -> NodeType
}

class GraphNavigationViewController<NodeType: Hashable, EdgeType: Edge>: UIViewController {
	var dataSource: GraphNavigationViewDataSource?
}