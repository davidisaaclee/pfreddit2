//
//  String+substringWithRange.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation

extension String {
	func substringWithRange(range: NSRange) -> String {
		return (self as NSString).substringWithRange(range)
	}
}
