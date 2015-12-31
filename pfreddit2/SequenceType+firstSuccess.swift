//
//  SequenceType+firstSuccess.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import BrightFutures
import Result

// TODO: I have the feeling that this extension is a fertile ground for memory leaks.
extension SequenceType where Self.Generator.Element: AsyncType, Self.Generator.Element.Value: ResultType {
	typealias ResultValue = Self.Generator.Element.Value.Value

	func firstSuccess() -> Future<ResultValue?,  NoError> {
		let promise = Promise<ResultValue?, NoError>()

		var didExit = false
		var pendingFutures = 0

		func succeeded(value: ResultValue) {
			if !didExit {
				didExit = true
				promise.success(value)
			}
		}
		func failed(_: ErrorType) {
			if !didExit {
				if --pendingFutures <= 0 {
					// Ran out of futures, with no successes.
					didExit = true
					promise.success(nil)
				}
			}
		}

		for future in self {
			pendingFutures++
			future
				.onSuccess(callback: succeeded)
				.onFailure(callback: failed)
		}
		return promise.future
	}
}