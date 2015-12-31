////
////  ImgurCommunication.swift
////  pfreddit
////
////  Created by David Lee on 11/19/15.
////  Copyright © 2015 David Lee. All rights reserved.
////
//
//import Foundation
//import BrightFutures
//
//// Let us make Range objects from NSRanges - c'mon Apple
//extension String {
//	func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
//		let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
//		let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
//		if let from = String.Index(from16, within: self),
//			let to = String.Index(to16, within: self) {
//				return from ..< to
//		}
//		return nil
//	}
//}
//
//
//extension Dictionary {
//	func mapValues<T>(transform: (Key, Value) -> T) -> Dictionary<Key, T> {
//		var result = Dictionary<Key, T>()
//		for key in self.keys {
//			result.updateValue(transform(key, self[key]!), forKey: key)
//		}
//		return result
//	}
//	
//	func filterValues(predicate: (Key, Value) -> Bool) -> Dictionary<Key, Value> {
//		var result = Dictionary<Key, Value>()
//		for key in self.keys {
//			if predicate(key, self[key]!) {
//				result[key] = self[key]!
//			}
//		}
//		return result
//	}
//}
//
//
//enum ImgurId {
//	case Image(id: String)
//	case Album(id: String)
//	case ImageInAlbum(albumId: String, imageId: String)
//	case Gallery(id: String)
//}
//
//class ImgurCommunication {
//	class func imgurIdFromURL(url: NSURL) -> ImgurId {
//		return ImgurCommunication.imgurIdFromURL(url.absoluteString)
//	}
//	
//	class func imgurIdFromURL(URLString: String) -> ImgurId {
//		var result: [String: String] = [:]
//		
//		let contentExt = "(?:jpg|gif|webm|gifv)"
//		let imageId = "[^#\\./]+"
//		let albumId = "[^#\\./]+"
//		let galleryId = "[^#\\./]+"
//		
//		let directPattern = "imgur.com/(\(imageId))(?:\\.\(contentExt))?"
//		let albumPattern = "imgur.com/a/(\(albumId))(?:#(\(imageId)))?"
//		let galleryPattern = "imgur.com/gallery/(\(galleryId))"
//		
//		let patterns = [
//			"image": "imgur.com/(\(imageId))(?:\\.\(contentExt))?",
//			"album": "imgur.com/a/(\(albumId))",
//			"imageInAlbum": "imgur.com/a/(\(albumId))(#(\(imageId)))?",
//			"gallery": "imgur.com/gallery/(\(galleryId))"
//		]
//		let regexes: [String: NSRegularExpression] = patterns.mapValues {
//			(kind, pattern) -> NSRegularExpression? in
//			do {
//				return try? NSRegularExpression(pattern: pattern, options: [])
//			}
//		}.filterValues {
//			$1 != nil
//		}.mapValues {
//			$1!
//		}
//		
//		let matches = regexes.mapValues {
//			(kind, regex) -> NSTextCheckingResult? in
//			return regex.firstMatchInString(URLString, options: [], range: NSMakeRange(0, URLString.characters.count))
//		}.filter { (_, match) -> Bool in match != nil }
//		print(matches)
//
//
//		return .Image(id: "null")
////		let matches = regexes.mapValues { key, regex in
////			
////		}
////		
////		if let match = regexes["image"]!.firstMatchInString(URLString, options: [], range: NSMakeRange(0, URLString.characters.count)) {
////			let substring = URLString.substringWithRange(URLString.rangeFromNSRange(match.rangeAtIndex(1))!)
////			if !substring.isEmpty {
////				return .Image(id: substring)
////			}
////		}
//		
//		
//		
////		let patternList = [
////			galleryPattern,
////			albumPattern,
////			directPattern
////		].map { "(?:\($0))" }
////		
////		let combinedPattern = patternList.dropFirst().reduce(patternList.first!, combine: { "\($0)|\($1)" })
////		var imgurRegexOpt: NSRegularExpression?
////		do {
////			imgurRegexOpt = try NSRegularExpression(pattern: combinedPattern, options: [])
////		} catch {
////			print("Invalid regex pattern")
////		}
////		
////		if let imgurRegex = imgurRegexOpt {
////			if let match = imgurRegex.firstMatchInString(URLString, options: [], range: NSMakeRange(0, URLString.characters.count)) {
////				["full", "gallery", "album", "imageInAlbum", "image"].enumerate().forEach {
////					let substring = URLString.substringWithRange(URLString.rangeFromNSRange(match.rangeAtIndex($0.0))!)
////					if !substring.isEmpty {
////						result[$0.1] = substring
////					}
////				}
////			}
////		}
//
//		
//	}
//	
////	class func getDirectLink(id: String, callback: ((link: String?, imgurId: String, error: ErrorType?) -> Void)) {
////		print("https://api.imgur.com/3/image/\(id)")
////		let url = NSURL(string: "https://api.imgur.com/3/image/\(id)")
////		let session = NSURLSession.sharedSession()
////		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
////		config.HTTPAdditionalHeaders = [ "Authentication": "Client-ID 7dff9b51653647a" ]
////		let dataTask = session.dataTaskWithRequest(NSURLRequest(URL: url!), completionHandler: { data, response, err -> Void in
////			let json = JSON(data: data!)
////			callback(link: json["data"]["link"].string, imgurId: id, error: nil)
//////			let directLinkKeys = [ "link", "gifv", "mp4", "webm" ]
//////			let filtered: [(String, JSON)] = json["data"].filter({ directLinkKeys.contains($0.0) })
//////			return filtered.map {
//////				$0.1.stringValue
//////			}
////		})
////		dataTask.resume()
////	}
//	
//	class func getDirectLink(id: String) -> Future<NSURL, NoError> {
//		let promise = Promise<NSURL, NoError>()
//		
//		let url = NSURL(string: "https://api.imgur.com/3/image/\(id)")
//		let session = NSURLSession.sharedSession()
//		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//		config.HTTPAdditionalHeaders = [ "Authentication": "Client-ID 7dff9b51653647a" ]
//		let dataTask = session.dataTaskWithRequest(NSURLRequest(URL: url!), completionHandler: { data, response, err -> Void in
//			let json = JSON(data: data!)
//			if let link = json["data"]["link"].string {
//				if let linkURL = NSURL(string: link) {
//					promise.success(linkURL)
//				}
//			}
//		})
//		dataTask.resume()
//		return promise.future
//	}
//	
//	class func getLink() {
//	}
//}