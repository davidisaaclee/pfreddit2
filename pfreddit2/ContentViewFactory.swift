//
//  ContentViewFactory.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation

func createContentViewForContent(content: ContentType) -> ContentViewController? {
	let controller = { content -> ContentViewController? in
		switch content {
		case .Webpage(_):
			return WebpageContentViewController()
		case .Image(_):
			return ImageContentViewController()
		case .InlineVideo(_):
			return InlineVideoContentViewController()
		default:
			return nil
		}
	}(content)
	return controller
}