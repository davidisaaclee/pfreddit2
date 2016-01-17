//
//  RedditDecodable.swift
//  pfreddit2
//
//  Created by David Lee on 1/17/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SwiftyJSON

extension RedditLink: Decodable {
	init?(json j: JSON)	{
		guard let id						= j["data"]["id"].string							else { return nil }
		guard let fullname		= j["data"]["name"].string						else { return nil }
		guard let kind					= j["kind"].string										else { return nil }
		guard let created_utc = j["data"]["created_utc"].double			else { return nil }
		guard let ups					= j["data"]["ups"].int								else { return nil }
		guard let downs				= j["data"]["downs"].int							else { return nil }
		let likes							= j["data"]["likes"].bool

		// the account name of the poster. null if this is a promotional link
		var author: Author!
		if let accountName = j["data"]["author"].string {
			author = Author.User(accountName: accountName)
		} else {
			author = Author.Promotional
		}

		// probably always returns false
		guard let clicked = j["data"]["clicked"].bool else { return nil }
		// the domain of this link. Self posts will be self.<subreddit> while other examples include en.wikipedia.org and s3.amazon.com
		guard let domain = j["data"]["domain"].string else { return nil }
		// true if the post is hidden by the logged in user. false if not logged in or not hidden.
		guard let hidden = j["data"]["hidden"].bool else { return nil }
		// true if this link is a selfpost
		guard let isSelf = j["data"]["is_self"].bool else { return nil }
		// the number of comments that belong to this link. includes removed comments.
		guard let numComments = j["data"]["num_comments"].int else { return nil }
		// true if the post is tagged as NSFW. False if otherwise
		guard let over18 = j["data"]["over_18"].bool else { return nil }
		// true if this post is saved by the logged in user
		guard let saved = j["data"]["saved"].bool else { return nil }
		// the net-score of the link. note: A submission's score is simply the number of upvotes minus the number of downvotes. If five users like the submission and three users don't it will have a score of 2. Please note that the vote numbers are not "real" numbers, they have been "fuzzed" to prevent spam bots etc. So taking the above example, if five users upvoted the submission, and three users downvote it, the upvote/downvote numbers may say 23 upvotes and 21 downvotes, or 12 upvotes, and 10 downvotes. The points score is correct, but the vote totals are "fuzzed".
		guard let score = j["data"]["score"].int else { return nil }
		// the raw text. this is the unformatted text which includes the raw markup characters such as ** for bold. <, >, and & are escaped. Empty if not present.
		let selftext = j["data"]["selftext"].string
		// the formatted escaped HTML text. this is the HTML formatted version of the marked up text. Items that are boldened by ** or *** will now have <em> or *** tags on them. Additionally, bullets and numbered lists will now be in HTML list format. NOTE: The HTML string will be escaped. You must unescape to get the raw HTML. Null if not present.
		let selftextHTML = j["data"]["selftext_html"].string
		// subreddit of thing excluding the /r/ prefix. "pics"
		guard let subreddit = j["data"]["subreddit"].string else { return nil }
		// the id of the subreddit in which the thing is located
		guard let subredditId = j["data"]["subreddit_id"].string else { return nil }
		// full URL to the thumbnail for this link; "self" if this is a self post; "default" if a thumbnail is not available
		var thumbnail: Thumbnail!
		guard let thumbnailInfo = j["data"]["thumbnail"].string else { return nil }
		switch thumbnailInfo {
		case "self":
			thumbnail = Thumbnail.SelfPost
		case "default":
			thumbnail = Thumbnail.None
		default:
			guard let thumbnailURL = NSURL(string: thumbnailInfo) else { return nil }
			thumbnail = Thumbnail.URL(URL: thumbnailURL)
		}
		// the title of the link. may contain newlines for some reason
		guard let title = j["data"]["title"].string else { return nil }
		// the link of this post. the permalink if this is a self-post
		guard let url = j["data"]["url"].string else { return nil }
		// Indicates if link has been edited. Will be the edit timestamp if the link has been edited and return false otherwise. https://github.com/reddit/reddit/issues/581
		var edited: NSDate?
		if let editedInterval = j["data"]["edited"].double {
			edited = NSDate(timeIntervalSince1970: editedInterval)
		} else {
			edited = .None
		}
		// to allow determining whether they have been distinguished by moderators/admins. null = not distinguished. moderator = the green [M]. admin = the red [A]. special = various other special distinguishes http://bit.ly/ZYI47B
		var distinguished: Distinguish!
		if let distinguishedString = j["data"]["distinguished"].string {
			switch distinguishedString {
			case "moderator":
				distinguished = Distinguish.Moderator
			case "admin":
				distinguished = Distinguish.Admin
			default:
				distinguished = Distinguish.Other(distinguishedString)
			}
		} else {
			distinguished = Distinguish.None
		}
		// true if the post is set as the sticky in its subreddit.
		guard let stickied: Bool = j["data"]["stickied"].bool else { return nil }

		self.id = id
		self.fullname = fullname
		self.kind = kind
		self.created = NSDate(timeIntervalSince1970: created_utc)
		self.ups = ups
		self.downs = downs
		self.likes = likes
		self.author = author
		self.clicked = clicked
		self.domain = domain
		self.hidden = hidden
		self.isSelf = isSelf
		self.numComments = numComments
		self.over18 = over18
		self.saved = saved
		self.score = score
		self.selftext = selftext
		self.selftextHTML = selftextHTML
		self.subreddit = subreddit
		self.subredditId = subredditId
		self.thumbnail = thumbnail
		self.title = title
		self.url = url
		self.edited = edited
		self.distinguished = distinguished
		self.stickied = stickied
	}
}
