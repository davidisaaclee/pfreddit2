//
//  RedditGraphStructures.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation

extension RealmContentNode {
	convenience init(link: RedditLink) {
		var thumbnailURL: String?
		if case let .URL(url) = link.thumbnail {
			thumbnailURL = url.absoluteString
		}

		self.init()
		self.id = link.id
		self.title = link.title
		self.thumbnailURL = thumbnailURL
		self.metadata = MetadataType.Reddit(id: link.id, score: link.ups)

		SharedContentParser.parseFromURLString(link.url).onSuccess { content in
			guard let SharedContentGraph = SharedContentGraph as? RealmContentGraph else {
				fatalError("RealmContentNode could not access RealmContentGraph.")
			}

			SharedContentGraph.safeWrite(self) { node, realm in
				node.content = content
			}.onFailure { error in
				print("Error writing content: ", error)
			}
		}.onFailure { error in
			print("Error parsing content: ", error)
		}
	}
}