//
//  RedditCommunicator.swift
//  pfreddit2
//
//  Created by David Lee on 12/21/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyJSON


// MARK: - Constants

struct RedditConstants {
	static let ModHashHeader = KeyValuePair(key: "-Modhash", value: "nzjp7svpla5650b2dc97a11c44c687e52a6d757777171cb5e3" )
	static func AfterHeader(afterValue: String) -> KeyValuePair {
		return KeyValuePair(key: "after", value: afterValue)
	}
}

typealias MediaData = String
typealias MediaEmbedData = String

enum RedditOrdering: String {
	case Hot = "hot"
	case Top = "top"
}

enum RedditCommunicationError: ErrorType {
	case HTTPError(NSError)
	case EmptyListing
	case RequestError(DataRequestor.Error)
	case EndOfListing
}


// MARK: - RedditCommunicator

class RedditCommunicator: NSObject {
	class func loadLinksFromSubreddit(subreddit: String, ordering: RedditOrdering = .Hot, count: Int = 25) -> Future<[RedditLink], RedditCommunicationError> {
		let urlString = "https://www.reddit.com/r/\(subreddit)/\(ordering.rawValue).json"
		let requestURLOpt = NSURL(string: urlString)

		guard let requestURL = requestURLOpt else {
			fatalError("Unable to construct Reddit URL internally.")
		}

		var headers: [String: String] = [:]
		headers[RedditConstants.ModHashHeader.key] = RedditConstants.ModHashHeader.value

		func loadLinksFromListing(listing: RedditListing<RedditLink>, count: Int) -> Future<[RedditLink], RedditCommunicationError> {
			if listing.children.count < count {
				return listing.next().flatMap { nextListing in
					return loadLinksFromListing(nextListing, count: count - listing.children.count)
				}
			} else {
				return Future(value: Array(listing.children.prefix(count)))
			}
		}

		return DataRequestor.requestHTTP(requestURL, HTTPAdditionalHeaders: headers)
			.mapError(RedditCommunicationError.RequestError)
			.flatMap { data -> Future<[RedditLink], RedditCommunicationError> in
				let json = JSON(data: data)
				if let listing = RedditListing<RedditLink>(json: json, request: requestURL) {
					return loadLinksFromListing(listing, count: count)
				} else {
					return Future(error: RedditCommunicationError.EndOfListing)
				}
			}
	}

	class func linkSequenceFromSubreddit(subreddit: String, ordering: RedditOrdering = .Hot) -> Future<RedditListingElementGenerator<RedditLink>, RedditCommunicationError> {
		let urlString = "https://www.reddit.com/r/\(subreddit)/\(ordering.rawValue).json"
		let requestURLOpt = NSURL(string: urlString)

		guard let requestURL = requestURLOpt else {
			fatalError("Unable to construct Reddit URL internally.")
		}

		var headers: [String: String] = [:]
		headers[RedditConstants.ModHashHeader.key] = RedditConstants.ModHashHeader.value

		return DataRequestor.requestHTTP(requestURL, HTTPAdditionalHeaders: headers)
			.mapError(RedditCommunicationError.RequestError)
			.flatMap { data -> Future<RedditListingElementGenerator<RedditLink>, RedditCommunicationError> in
				let json = JSON(data: data)
				if let listing = RedditListing<RedditLink>(json: json, request: requestURL),
					 let generator = listing.asyncElementGenerator() {
					return Future(value: generator)
				} else {
					// TODO: Invalid listing data
					return Future(error: RedditCommunicationError.EmptyListing)
				}
			}
	}
}