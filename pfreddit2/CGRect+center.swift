//
//  CGRect+center.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation

import UIKit

extension CGRect {
	var center: CGPoint {
		get {
			return CGPoint(x: origin.x + width / 2.0, y: origin.y + height / 2.0)
		}
		set {
			origin = CGPoint(x: newValue.x - width / 2.0, y: newValue.y - height / 2.0)
		}
	}
}