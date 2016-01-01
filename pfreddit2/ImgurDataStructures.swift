//
//  ImgurDataStructures.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import SwiftyJSON

// NOTE: Truncated from base Imgur model - see https://api.imgur.com/models/image
struct ImgurImageModel: Decodable {
	// id	string	The ID for the image
	let id: String
	// animated	boolean	is the image animated
	let animated: Bool
	// width	integer	The width of the image in pixels
	let width: Int
	// height	integer	The height of the image in pixels
	let height: Int
	// link	string	The direct link to the the image. (Note: if fetching an animated GIF that was over 20MB in original size, a .gif thumbnail will be returned)
	let link: String

	// gifv   	string 	OPTIONAL, The .gifv link. Only available if the image is animated and type is 'image/gif'.
	// mp4    	string 	OPTIONAL, The direct link to the .mp4. Only available if the image is animated and type is 'image/gif'.
	// webm   	string 	OPTIONAL, The direct link to the .webm. Only available if the image is animated and type is 'image/gif'.
	// looping	boolean	OPTIONAL, Whether the image has a looping animation. Only available if the image is animated and type is 'image/gif'.

	init?(json: JSON) {
		guard let success = json["success"].bool else { return nil }
		guard success else { return nil }

		let data = json["data"]

		guard let id = data["id"].string else {
			return nil
		}
		guard let animated = data["animated"].bool else { return nil }
		guard let width = data["width"].int else { return nil }
		guard let height = data["height"].int else { return nil }
		guard let link = data["link"].string else { return nil }

		self.id = id
		self.animated = animated
		self.width = width
		self.height = height
		self.link = link
	}
}