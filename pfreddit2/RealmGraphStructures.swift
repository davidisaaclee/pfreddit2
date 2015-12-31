//
//  RealmGraphStructures.swift
//  pfreddit2
//
//  Created by David Lee on 12/29/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import BrightFutures
import RealmSwift

// Object representation of `ContentType` enum for storage in Realm database.
class ContentTypeObject: Object {
	private struct TypeString {
		static let Image: String = "Image"
		static let InlineVideo: String = "InlineVideo"
		static let Webpage: String = "Webpage"
		static let Unknown: String = "Unknown"
	}

	dynamic var contentType: String?
	dynamic var url: String?

	convenience init(content: ContentType) {
		self.init()

		switch content {
		case let .Image(imageURL):
			contentType = TypeString.Image
			url = imageURL.absoluteString

		case let .InlineVideo(videoURL):
			contentType = TypeString.InlineVideo
			url = videoURL.absoluteString

		case let .Webpage(pageURL):
			contentType = TypeString.Webpage
			url = pageURL.absoluteString

		case let .Unknown(urlString):
			contentType = TypeString.Unknown
			url = urlString
		}
	}

	func asContentType() -> ContentType? {
		guard let contentType = contentType else { return nil }

		switch contentType {
		case TypeString.Image:
			guard let urlString = self.url,
				let url = NSURL(string: urlString) else { return nil }
			return ContentType.Image(url)

		case TypeString.InlineVideo:
			guard let urlString = self.url,
				let url = NSURL(string: urlString) else { return nil }
			return ContentType.InlineVideo(url)

		case TypeString.Webpage:
			guard let urlString = self.url,
				let url = NSURL(string: urlString) else { return nil }
			return ContentType.Webpage(url)

		default:
			return nil
		}
	}
}

class RealmContentNode: Object, ContentNode {
	dynamic var id: String = ""
	dynamic var title: String = ""
	dynamic var thumbnailURL: String?
	dynamic var selftext: String?

	dynamic var contentObject: ContentTypeObject?
	var content: ContentType? {
		set {
			guard let newValue = newValue else {
				contentObject = nil
				return
			}
			contentObject = ContentTypeObject(content: newValue)
		}
		get {
			return contentObject?.asContentType()
		}
	}

	convenience init(node: ContentNode) {
		self.init()
    id = node.id
    title = node.title
    thumbnailURL = node.thumbnailURL
    selftext = node.selftext
		if let nodeContent = node.content {
			contentObject = ContentTypeObject(content: nodeContent)
		}
	}

	override static func primaryKey() -> String? {
		return "id"
	}
}

extension RealmContentNode: Hashable {}
func ==(lhs: RealmContentNode, rhs: RealmContentNode) -> Bool {
	return lhs.id == rhs.id
}

class RealmContentEdge: Object, ContentEdge {
	dynamic var id: String = ""
	dynamic var weight: Double = 0.0
	dynamic var weightFollowedEdge: Int = 0 { didSet { recalculateWeight() } }

	var sourceNode: ContentNode! {
		return realmSourceNode as? ContentNode
	}
	var destinationNode: ContentNode! {
		return realmDestinationNode as? ContentNode
	}

	dynamic var realmSourceNode: RealmContentNode? { didSet { updateID() } }
	dynamic var realmDestinationNode: RealmContentNode? { didSet { updateID() } }


	override var description: String {
		return "\(id) (\(weight))"
	}

	convenience init(sourceNode: RealmContentNode, destinationNode: RealmContentNode) {
		self.init()
		self.realmSourceNode = sourceNode
		self.realmDestinationNode = destinationNode
	}

	override static func primaryKey() -> String? {
		return "id"
	}

	func recalculateWeight() {
		self.weight = Double(weightFollowedEdge)
	}

	private func updateID() {
		guard realmSourceNode != nil && realmDestinationNode != nil else { return }
		self.id = "(\(sourceNode.id) -> \(destinationNode.id))"
	}
}