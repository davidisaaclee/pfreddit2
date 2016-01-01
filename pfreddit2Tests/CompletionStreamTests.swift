//
//  CompletionStreamTests.swift
//  pfreddit2
//
//  Created by David Lee on 12/31/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import XCTest
import BrightFutures
//import pfreddit2

import Result

// HACK: Can't figure out how to test extension right now.
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

class CompletionStreamTests: XCTestCase {
	enum TestError: ErrorType {
		case Error1
		case Error2
	}

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testAccepting1() {
		let promise1 = Promise<Int, TestError>()
		let promise2 = Promise<Int, TestError>()

		let futureSequence = [promise1.future, promise2.future]

		func isEven(n: Int) -> Bool {
			return n % 2 == 0
		}

		futureSequence.completionStream { result in
			guard let value = result.value else {
				XCTAssert(false)
				fatalError()
			}
			return isEven(value)
		}.onSuccess { resultOrNil in
			XCTAssert(resultOrNil != nil)
			XCTAssert(resultOrNil!.value != nil)
			XCTAssert(resultOrNil!.value! == 1)
		}

		promise2.success(2)
		promise1.success(1)
	}

	func testAccepting2() {
		let promise1 = Promise<Int, TestError>()
		let promise2 = Promise<Int, TestError>()

		let futureSequence = [promise1.future, promise2.future]

		func isEven(n: Int) -> Bool {
			return n % 2 == 0
		}

		futureSequence.completionStream { result in
			guard let value = result.value else {
				XCTAssert(false)
				fatalError()
			}
			return isEven(value)
			}.onSuccess { resultOrNil in
				XCTAssert(resultOrNil != nil)
				XCTAssert(resultOrNil!.value != nil)
				XCTAssert(resultOrNil!.value! == 1)
		}

		promise1.success(1)
		promise2.success(2)
	}

	func testAccepting3() {
		let promise1 = Promise<Int, TestError>()
		let promise2 = Promise<Int, TestError>()
		let promise3 = Promise<Int, TestError>()

		let futureSequence = [promise1.future, promise2.future, promise3.future]

		func isEven(n: Int) -> Bool {
			return n % 2 == 0
		}

		futureSequence.completionStream { result in
			guard let value = result.value else {
				XCTAssert(false)
				fatalError()
			}
			return isEven(value)
		}.onSuccess { resultOrNil in
			XCTAssert(resultOrNil != nil)
			XCTAssert(resultOrNil!.value != nil)
			XCTAssert(resultOrNil!.value! == 1)
		}

		promise2.success(2)
		promise1.success(4)
		promise3.success(1)
	}

	func testNoAccept() {
		let promise1 = Promise<Int, TestError>()
		let promise2 = Promise<Int, TestError>()
		let promise3 = Promise<Int, TestError>()

		let futureSequence = [promise1.future, promise2.future, promise3.future]

		func isEven(n: Int) -> Bool {
			return n % 2 == 0
		}

		futureSequence.completionStream { result in
			guard let value = result.value else {
				XCTAssert(false)
				fatalError()
			}
			return isEven(value)
		}.onSuccess { resultOrNil in
			XCTAssert(resultOrNil == nil)
		}

		promise2.success(2)
		promise1.success(4)
		promise3.success(2)
	}
}
