//
//  SequenceType+completionStream.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import BrightFutures
import Result

extension SequenceType where Self.Generator.Element: AsyncType, Self.Generator.Element.Value: ResultType {
	// Block is supplied the completed `Result`, and returns `true` if stream should continue, else `false`.
	func completionStream(block: Self.Generator.Element.Value -> Bool) -> Self {
		var isStreaming = true

		for future in self {
			// TODO: Learn what this queue business is all about.
			future.onComplete(Queue.global.context) { result in
				if isStreaming {
					isStreaming = block(result)
				}
 			}
		}

		return self
	}
}