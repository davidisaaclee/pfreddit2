//
//  ContentService.swift
//  pfreddit2
//
//  Created by David Lee on 1/14/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import BrightFutures

enum ContentServiceError: ErrorType {
	case External(ErrorType)
}

protocol ContentService {
	// Call to fetch nodes to prepopulate the database.
	// Outer `Future` represents communication with the service; the inner `Future`s represent requesting each
	//	 individual node.
	func prefetchNodes(count: Int) -> Future<[Future<ContentNode, ContentServiceError>], ContentServiceError>

	// Fetch edges pointing to nodes related to the provided source node.
	func fetchOutgoingEdgesFromNode(node: ContentNode, count: Int) -> [Future<ContentEdge, ContentServiceError>]
}