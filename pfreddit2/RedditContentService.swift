//
//  RedditContentService.swift
//  pfreddit2
//
//  Created by David Lee on 1/14/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import BrightFutures

class RedditContentService: NSObject, ContentService {
	// Call to fetch nodes to prepopulate the database.
	func prefetchNodes(count: Int) -> Future<[Future<ContentNode, ContentServiceError>], ContentServiceError> {
		return RedditCommunicator.linkSequenceFromSubreddit("all").map { (gen: RedditListingElementGenerator<RedditLink>) -> [Future<ContentNode, ContentServiceError>] in
			return GeneratorSequence<RedditListingElementGenerator<RedditLink>>(gen).prefix(count).map { futureLink in
				return futureLink.mapError(ContentServiceError.External).map(RealmContentNode.init)
			}
		}.mapError(ContentServiceError.External)
	}

	// Fetch edges pointing to nodes related to the provided source node.
	func fetchOutgoingEdgesFromNode(node: ContentNode, count: Int) -> [Future<ContentEdge, ContentServiceError>] {
		// TODO
		return []
	}
}