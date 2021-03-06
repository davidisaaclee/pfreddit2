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
		static let AnimatedImage: String = "AnimatedImage"
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

		case let .AnimatedImage(videoURL):
			contentType = TypeString.AnimatedImage
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

		case TypeString.AnimatedImage:
			guard let urlString = self.url,
				let url = NSURL(string: urlString) else { return nil }
			return ContentType.AnimatedImage(url)

		case TypeString.Webpage:
			guard let urlString = self.url,
				let url = NSURL(string: urlString) else { return nil }
			return ContentType.Webpage(url)

		default:
			return nil
		}
	}
}

class MetadataTypeObject: Object {
	private struct TypeString {
		static let Reddit = "Reddit"
	}

	dynamic var type: String!
	dynamic var id: String!
	dynamic var score: Int = 0

	convenience init(metadata: MetadataType) {
		self.init()
		switch metadata {
		case let .Reddit(id, score):
			self.type = TypeString.Reddit
			self.id = id
			self.score = score
		}
	}

	func asMetadataType() -> MetadataType? {
		switch self.type {
		case TypeString.Reddit:
			return MetadataType.Reddit(id: self.id, score: self.score)

		default:
			return nil
		}
	}
}

class RealmContentNode: Object, ContentNode {
	dynamic var id: String = ""
	dynamic var title: String = ""
	dynamic var thumbnailURL: String?

	dynamic var metadataObject: MetadataTypeObject?
	var metadata: MetadataType? {
		set {
			guard let newValue = newValue else {
				metadataObject = nil
				return
			}
			metadataObject = MetadataTypeObject(metadata: newValue)
		}
		get {
			return metadataObject?.asMetadataType()
		}
	}

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
    metadata = node.metadata
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

// Describes interactions with a ContentNode which affect associated edge weights.
class RealmContentNodeWeighting: Object, ContentNodeWeighting {
	dynamic var nodeID: String = ""
	dynamic var seenByActiveUser: Bool = false

	dynamic var weightAsSourceNode: Double = 0.0
	dynamic var weightAsDestinationNode: Double = 0.0

	func recalculateWeight() {
		weightAsSourceNode = 0.0
		weightAsDestinationNode = seenByActiveUser ? -100 : 0
	}

	convenience init(node: ContentNode) {
		self.init()
		nodeID = node.id
		recalculateWeight()
	}
}


class RealmContentEdge: Object, ContentEdge {
	dynamic var id: String = ""
	dynamic var weight: Double = 0.0

	// Specific weights
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
		recalculateWeight()
	}

	override static func primaryKey() -> String? {
		return "id"
	}

	func recalculateWeight() {
		SharedContentGraph.nodeWeightingForID(self.sourceNode.id)
			.zip(SharedContentGraph.nodeWeightingForID(self.destinationNode.id))
			.onSuccess { (sourceNodeWeighting, destinationNodeWeighting) in
				let sourceNodeWeight: Double = sourceNodeWeighting?.weightAsSourceNode ?? 0
				let destinationNodeWeight: Double = destinationNodeWeighting?.weightAsDestinationNode ?? 0

				// TODO: exceptions
				try! self.realm?.write {
					self.weight = Double(self.weightFollowedEdge)
											+ sourceNodeWeight
											+ destinationNodeWeight
				}
			}
	}

	private func updateID() {
		guard realmSourceNode != nil && realmDestinationNode != nil else { return }
		self.id = "(\(sourceNode.id) -> \(destinationNode.id))"
	}
}