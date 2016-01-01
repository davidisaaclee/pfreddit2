//
//  ImgurParser.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyJSON

class ImgurParser: ContentParserModule {
	struct Patterns {
		private typealias R = RegexUtilities

		static let contentExt = "(?:jpg|gif|webm|gifv)"
		static let imageId = "[^#\\./]+"
		static let albumId = "[^#\\./]+"
		static let galleryId = "[^#\\./]+"

		static let imageURL: String = "^"
			+ R.URL.HTTP
			+ R.Optional(R.URL.WWW)
			+ R.Optional("i\\.")
			+ R.Optional("m\\.")
			+ "imgur\\.com"
			+ "/"
			+ R.CapturingGroup(R.LengthRange(R.Set([R.WordCharacter, R.DigitCharacter]), lower: 3))
			+ R.Optional("\\." + R.Union(["jpg", "gif", "png"]))

//		static let patterns = [
//			"image": "imgur.com/(\(imageId))(?:\\.\(contentExt))?",
//			"album": "imgur.com/a/(\(albumId))",
//			"imageInAlbum": "imgur.com/a/(\(albumId))(#(\(imageId)))?",
//			"gallery": "imgur.com/gallery/(\(galleryId))"
//		]
	}



	func parseFromURL(url: NSURL) -> Future<ContentType?, ContentParser.Error> {
		guard let directImageURLRegex: NSRegularExpression = try! NSRegularExpression(pattern: Patterns.imageURL, options: []) else {
			return Future(value: nil)
		}

		if let match = simpleRegexMatch(directImageURLRegex, string: url.absoluteString) {
			let imageIdRangeIndex = 1
			let imageID = url.absoluteString.substringWithRange(match.rangeAtIndex(imageIdRangeIndex))

			return requestImageDataFromID(imageID).mapError { dataRequestorError in
				return ContentParser.Error.ServiceError(service: "Imgur", error: dataRequestorError)
			}.map { imgurImage -> ContentType? in
				guard let imgurImage = imgurImage else {
					print("Could not parse response from Imgur", url.absoluteString)
					return nil
				}

				if imgurImage.animated {
					// TODO
					print("Animated images not yet supported.")
					return nil
				} else {
					guard let imageURL = NSURL(string: imgurImage.link) else { return nil }
					return ContentType.Image(imageURL)
				}
			}.onFailure { error in
				print("Could not create internal Imgur representation for URL \(url.absoluteString):", error)
			}
		} else {
			return Future(value: nil)
		}
	}

	func requestImageDataFromID(imageId: String) -> Future<ImgurImageModel?, DataRequestor.Error> {
		guard let requestURL = NSURL(string: "https://api.imgur.com/3/image/\(imageId)") else {
			return Future(error: DataRequestor.Error.InvalidURL)
		}

		let headers: [String: String] = [
			"Authorization": "Client-ID 7dff9b51653647a"
		]

		return DataRequestor.requestHTTP(requestURL, HTTPAdditionalHeaders: headers)
			.mapError { error in DataRequestor.Error.ExternalError(error) }
			.map { JSON(data: $0) }
			.map(ImgurImageModel.init)
	}

	private func simpleRegexMatch(regex: NSRegularExpression, string: String) -> NSTextCheckingResult? {
		return regex.firstMatchInString(string, options: [], range: NSRange(location: 0, length: string.utf16.count))
	}
}
