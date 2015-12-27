//
//  RedditDataStructures.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation

protocol RedditVotable {
	var ups: Int { get }
	var downs: Int { get }
	// how the logged-in user has voted on the link - True = upvoted, False = downvoted, null = no vote
	var likes: Optional<Bool> { get }
}

protocol RedditCreated {
	var created: NSDate { get }
}

protocol RedditThing {
	var id: String { get }
	var fullname: String { get }
	var kind: String { get }
}

enum Author {
	case User(accountName: String)
	case Promotional
}

enum Thumbnail {
	case URL(URL: NSURL)
	case SelfPost
	case None
}

enum Distinguish {
	case None
	case Moderator
	case Admin
	case Other(String)
}

struct RedditLink: RedditThing, RedditCreated, RedditVotable {
	// RedditThing
	let id: String
	let fullname: String
	let kind: String

	// RedditCreated
	let created: NSDate

	// RedditVotable
	let ups: Int
	let downs: Int
	let likes: Bool?

	// RedditLink
	// the account name of the poster. null if this is a promotional link
	let author: Author
	// probably always returns false
	let clicked: Bool
	// the domain of this link. Self posts will be self.<subreddit> while other examples include en.wikipedia.org and s3.amazon.com
	let domain: String
	// true if the post is hidden by the logged in user. false if not logged in or not hidden.
	let hidden: Bool
	// true if this link is a selfpost
	let isSelf: Bool
	// the number of comments that belong to this link. includes removed comments.
	let numComments: Int
	// true if the post is tagged as NSFW. False if otherwise
	let over18: Bool
	// true if this post is saved by the logged in user
	let saved: Bool
	// the net-score of the link. note: A submission's score is simply the number of upvotes minus the number of downvotes. If five users like the submission and three users don't it will have a score of 2. Please note that the vote numbers are not "real" numbers, they have been "fuzzed" to prevent spam bots etc. So taking the above example, if five users upvoted the submission, and three users downvote it, the upvote/downvote numbers may say 23 upvotes and 21 downvotes, or 12 upvotes, and 10 downvotes. The points score is correct, but the vote totals are "fuzzed".
	let score: Int
	// the raw text. this is the unformatted text which includes the raw markup characters such as ** for bold. <, >, and & are escaped. Empty if not present.
	let selftext: String?
	// the formatted escaped HTML text. this is the HTML formatted version of the marked up text. Items that are boldened by ** or *** will now have <em> or *** tags on them. Additionally, bullets and numbered lists will now be in HTML list format. NOTE: The HTML string will be escaped. You must unescape to get the raw HTML. Null if not present.
	let selftextHTML: String?
	// subreddit of thing excluding the /r/ prefix. "pics"
	let subreddit: String
	// the id of the subreddit in which the thing is located
	let subredditId: String
	// full URL to the thumbnail for this link; "self" if this is a self post; "default" if a thumbnail is not available
	let thumbnail: Thumbnail
	// the title of the link. may contain newlines for some reason
	let title: String
	// the link of this post. the permalink if this is a self-post
	let url: String
	// Indicates if link has been edited. Will be the edit timestamp if the link has been edited and return false otherwise. https://github.com/reddit/reddit/issues/581
	let edited: NSDate?
	// to allow determining whether they have been distinguished by moderators/admins. null = not distinguished. moderator = the green [M]. admin = the red [A]. special = various other special distinguishes http://bit.ly/ZYI47B
	let distinguished: Distinguish
	// true if the post is set as the sticky in its subreddit.
	let stickied: Bool
}