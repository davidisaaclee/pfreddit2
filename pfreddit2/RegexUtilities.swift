//
//  RegexUtilities.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation

struct RegexUtilities {
	struct URL {
		static let HTTP: String = "(?:(?:https)|(?:http))://"
		static let WWW: String = "(?:www\\.)"
	}

	static func Optional(pattern: String) -> String {
		return "(?:\(pattern))?"
	}

	static func Union(patterns: [String], shouldWrap: Bool = true) -> String {
		let cookedPatterns = shouldWrap ? patterns.map(NoncapturingGroup) : patterns

		var result = "(?:"
		for i in 0..<cookedPatterns.count {
			if i == cookedPatterns.count - 1 {
				result += cookedPatterns[i]
			} else {
				result += "\(cookedPatterns[i])|"
			}
		}
		result += ")"
		return result
	}

	static let WordCharacter: String = "\\w"
	static let DigitCharacter: String = "\\w"

	static func Set(patterns: [String], shouldWrap: Bool = true) -> String {
		let cookedPatterns = shouldWrap ? patterns.map(NoncapturingGroup) : patterns
		return "[\(cookedPatterns.reduce("") { $0 + $1 })]"
	}

	static func NoncapturingGroup(pattern: String) -> String {
		return "(?:\(pattern))"
	}

	static func CapturingGroup(pattern: String) -> String {
		return "(\(pattern))"
	}

	static func LengthRange(pattern: String, lower: Int, upper: Int? = nil) -> String {
		if let upper = upper {
			if upper == lower {
				return "(?:\(pattern)){\(lower)}"
			} else {
				return "(?:\(pattern)){\(lower),\(upper)}"
			}
		} else {
			return "(?:\(pattern)){\(lower),}"
		}
	}
}