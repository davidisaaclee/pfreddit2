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
//		self.linkURL = link.url
		self.selftext = link.selftext
	}
}