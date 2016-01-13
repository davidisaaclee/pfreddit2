//
//  ContentTypes.swift
//  pfreddit2
//
//  Created by David Lee on 12/28/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import UIKit

enum ContentType {
	case Image(NSURL)
	// gifs, html video
	case AnimatedImage(NSURL)
	case Webpage(NSURL)
	case Unknown(String)
}

enum MetadataType {
	case Reddit(id: String, score: Int)
}