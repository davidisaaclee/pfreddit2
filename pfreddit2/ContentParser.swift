//
//  ContentParser.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import BrightFutures

protocol ContentParserModule {
	func parseFromURL(url: NSURL) -> Future<ContentType?, ContentParser.Error>
}

class ContentParser {
	enum Error: ErrorType {
		case InvalidURL(urlString: String)
		case ServiceError(service: String, error: ErrorType)
		case CouldNotMatch(urlString: String)
	}

	var modules: [ContentParserModule] = []
	var fallback: ContentParserModule?

	convenience init(modules: [ContentParserModule], fallback: ContentParserModule? = nil) {
		self.init()
		self.modules = modules
		self.fallback = fallback
	}

	func parseFromURLString(urlString: String) -> Future<ContentType, ContentParser.Error> {
		let promise = Promise<ContentType, ContentParser.Error>()
		guard let url = NSURL(string: urlString) else {	return Future(error: ContentParser.Error.InvalidURL(urlString: urlString)) }

		modules.map { $0.parseFromURL(url) }.completionStream { result -> Bool in
			if let contentOrNil = result.value, let content = contentOrNil {
//				promise.success(content)
				return true
			} else {
				return false
			}
		}.onSuccess { acceptedResultOrNil in
			if let acceptedResult = acceptedResultOrNil,
					let contentOrNil = acceptedResult.value,
					let content = contentOrNil {
				promise.success(content)
			} else {
				// nothing succeeded - fallback if possible
				guard let fallback = self.fallback else {
					promise.failure(ContentParser.Error.CouldNotMatch(urlString: urlString))
					return
				}
				fallback.parseFromURL(url).onSuccess { content in
					if let content = content {
						promise.success(content)
					} else {
						// Not even fallback could handle .... Uh, oh!
						promise.failure(ContentParser.Error.CouldNotMatch(urlString: urlString))
					}
				}.onFailure { error in
					promise.failure(error)
				}
			}
		}

		

		return promise.future
	}
}

class WebpageContentParser: ContentParserModule {
	func parseFromURL(url: NSURL) -> Future<ContentType?, ContentParser.Error> {
		return Future(value: ContentType.Webpage(url))
	}
}