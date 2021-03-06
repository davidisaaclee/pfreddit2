//
//  CommunicationUtilities.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyJSON

class DataRequestor: NSObject {
	enum Error: ErrorType {
		case InvalidURL
		case ParseError // idk how to do error types
		case ExternalError(NSError)
	}

	class func requestHTTP(url: NSURL, HTTPAdditionalHeaders: [String: String]?) -> Future<NSData, DataRequestor.Error> {
		let promise = Promise<NSData, DataRequestor.Error>()

		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		config.HTTPAdditionalHeaders = HTTPAdditionalHeaders
		let urlSession = NSURLSession.sharedSession()

		let dataTask = urlSession.dataTaskWithRequest(NSURLRequest(URL: url)) { (dataOrNil, responseOrNil, errorOrNil) -> Void in
			if let data = dataOrNil {
				promise.success(data)
			} else {
				promise.failure(DataRequestor.Error.ExternalError(errorOrNil!))
			}
		}
		dataTask.resume()

		return promise.future
	}
}



struct KeyValuePair {
	let key: String
	let value: String

	static func keyValuePairsAsDictionary(pairs: KeyValuePair...) -> [String: String] {
		return pairs.reduce([String: String]()) { (var dictionary, pair) in
			dictionary[pair.key] = pair.value
			return dictionary
		}
	}
}

extension KeyValuePair {
	func asURLQueryItem() -> NSURLQueryItem {
		return NSURLQueryItem(name: key, value: value)
	}
}



protocol Decodable {
	init?(json: JSON)
}
