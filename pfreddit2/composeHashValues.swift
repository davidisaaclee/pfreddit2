//
//  composeHashValues.swift
//  pfreddit2
//
//  Created by David Lee on 12/22/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation

func composeHashValues(hashes: Int..., m: Int = 3) -> Int {
	return hashes.reduce(0) { acc, elm in
		return m * acc + elm
	}
}