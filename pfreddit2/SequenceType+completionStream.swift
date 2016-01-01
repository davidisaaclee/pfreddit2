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
	typealias ElementResultType = Self.Generator.Element.Value

	// Block is supplied the completed `Result`, and returns `true` if stream should continue, else `false`.
	// Returns a `Future` of the final `Result`, or a `Future` of `nil` if no completion was accepted.
	public func completionStream(block: ElementResultType -> Bool) -> Future<ElementResultType?, NoError> {
		let promise = Promise<ElementResultType?, NoError>()
		var isStreaming = true
		var pendingFutures = 0

		for future in self {
			pendingFutures++

			// TODO: Learn what this queue business is all about.
			future.onComplete(Queue.global.context) { result in
				if isStreaming {
					let shouldContinueStreaming = block(result)
					if !shouldContinueStreaming {
						isStreaming = false
						promise.success(result)
						return
					}

					if --pendingFutures == 0 {
						isStreaming = false
						promise.success(nil)
					}
				}
 			}
		}

		return promise.future
	}
}