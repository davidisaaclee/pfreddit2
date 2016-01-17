//
//  RedditListingControllers.swift
//  pfreddit2
//
//  Created by David Lee on 1/17/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyJSON

// MARK: - RedditListingElementGenerator

class RedditListingElementGenerator<ListingElement where ListingElement: RedditThing, ListingElement: Decodable>: GeneratorType {
	// overriding Generator.Element
	typealias Element = Future<ListingElement, RedditCommunicationError>

	// listing - the Reddit listing for the page.
	// start - the sequential index of the first element in the page.
	private typealias Page = (listing: RedditListing<ListingElement>, start: Int)

	// the index of the next element to be retrieved.
	private var index: Int!
	private var cachedPages: [String: Future<Page, RedditCommunicationError>] = [:]

	// key into `cachedPages` for the Page with the highest `start`
	private var latestPageKey: String!
	private var latestPage: Future<Page, RedditCommunicationError>! { return cachedPages[latestPageKey] }

	init(currentListing: RedditListing<ListingElement>, initialCount: Int = 0) {
		let pageKey = currentListing.before ?? "null"

		self.cachedPages[pageKey] = Future(value: (listing: currentListing, start: initialCount))
		self.latestPageKey = pageKey
		self.index = initialCount
	}


	// MARK: - GeneratorType

	// Returns the next listing element in the order provided by Reddit.
	func next() -> Element? {
		/*
		Since the generator is only ever moving sequentially forward, the next element should always either be on the `latestPage`,
			or on some page after `latestPage`.
		Furthermore, this means that it's okay if we only fetch/cache pages sequentially, since we won't ever be skipping pages, or needing
			to go back a page.

		Since we need to index into the page asynchronously (once it has been loaded), we need to hold onto an index pointing to the
			desired element. This will be derived from the current value of `self.index`, which we'll capture in a local variable `currentIndex`.
		*/

		let currentIndex = self.index
		self.index = self.index + 1

		return self.pageForIndex(currentIndex).map { (listing, start) in
			return listing.children[currentIndex - start]
		}
	}


	// MARK: - Helper functions

	// Checks if the provided `page` should have an element at the provided `index`.
	// (A `Page` `p` should have elements within the range `[p.start, p.start + p.listing.children.count)`.)
	private func pageContainsIndex(index: Int, page: Page) -> Bool {
		let indexRange = page.start..<page.start + page.listing.children.count
		return indexRange.contains(index)
	}

	// Returns the `Page` which contains the element at the provided `index`. First searches through `cachedPages`; if can't find matching page,
	//   requests the next page, and tries again.
	// 
	// NOTE: Searching through `cachedPages` means waiting until all of the future `cachedPages` have completed. However, given the sequential nature of
	//   generators, this is a fine constraint, since it means that we'll always be waiting for a minimal number of futures to complete.
	//
	// Contract: `index` will be >= `latestPage!.start`
	private func pageForIndex(index: Int) -> Future<Page, RedditCommunicationError> {
		return cachedPageForIndex(index)
			// HACK: Force error type from `NoError` to `RedditCommunicationError`.
			//       (The block will never be called, since `cachedPageForIndex:` will never fail.)
			.mapError { _ in RedditCommunicationError.EmptyListing }
			.flatMap { pageOrNil -> Future<Page, RedditCommunicationError> in
				if let page = pageOrNil {
					// If we found a cached Page, we're all set.
					return Future(value: page)
				} else {
					// Otherwise, start paging in new Pages after `latestPage`.
					return self.latestPage.flatMap(self.fetchContainingPageForIndex(index))
				}
		}
	}

	// Searches through the list of future pages for a page with an index range containing
	//	 `index`, where the index range of a `Page` `p` is equal to `p.start..<(p.start + p.listing.children.count)`.
	// Returns `nil` if no such page in current `cachedPages`.
	// TODO: Check for leaks.
	private func cachedPageForIndex(index: Int) -> Future<Page?, NoError> {
		let promise = Promise<Page?, NoError>()
		var finished = false
		var pending = cachedPages.values.count

		cachedPages.values.forEach { futurePage in
			futurePage.onComplete { value in
				if !finished {
					if let page = value.value {
						if self.pageContainsIndex(index, page: page) {
							promise.success(page)
							finished = true
							return
						}
					}
					pending = pending - 1
					if pending == 0 {
						promise.success(nil)
						// TODO: put this back in; leaving out now so that BrightFutures will give us an error if we fulfill promise multiple times
						// finished = true
					}
				} else {
					guard promise.future.isCompleted else {
						// TODO: I'm really uncertain how this would be hit. Leaving it in for now, but I think it would be safe to take out.
						fatalError("`cachedPageForIndex` thinks it's finished but it ain't finished")
					}
				}
			}
		}
		return promise.future
	}

	// Finds the page which should hold the element at the specified `index`, in the case that such a page is expected to
	//   come after an already fetched page `afterPage`.
	private func fetchContainingPageForIndex(index: Int)(afterPage: Page) -> Future<Page, RedditCommunicationError> {
		return self.fetchPageAfter(afterPage).flatMap { nextPage -> Future<Page, RedditCommunicationError> in
			if self.pageContainsIndex(index, page: nextPage) {
				return Future(value: nextPage)
			} else {
				return self.fetchContainingPageForIndex(index)(afterPage: nextPage)
			}
		}
	}


	// If the page after `previousPage` hasn't been requested yet, begins a request future for the next page after
	//   `previousPage` and puts the future into the cache; otherwise, retrieves the pending request future from the cache.
	private func fetchPageAfter(previousPage: Page) -> Future<Page, RedditCommunicationError> {
		guard let nextPageKey = previousPage.listing.after else {
			return Future(error: RedditCommunicationError.EndOfListing)
		}

		if let nextPage = cachedPages[nextPageKey] {
			return nextPage
		} else {
			let futurePage = previousPage.listing.next().map { nextListing in
				return (listing: nextListing, start: previousPage.start + previousPage.listing.children.count)
			}

			cachedPages[nextPageKey] = futurePage
			latestPageKey = nextPageKey

			return futurePage
		}
	}
}


// MARK: - RedditListing

class RedditListing<Element where Element: RedditThing, Element: Decodable> {
	typealias RedditListingRequest = NSURL

	// points to the page before this page
	let before: String?
	// points to the page after this page
	let after: String?
	let children: [Element]

	private let request: RedditListingRequest

	init?(json: JSON, request: RedditListingRequest) {
		assert(json["kind"].string! == "Listing")

		let before = json["data"]["before"].string
		let after = json["data"]["after"].string
		guard let children = json["data"]["children"].array?.map(Element.init).flatMap({ $0 }) else {
			// TODO: Realm tells me I need to initialize stored properties before returning nil; why?
			self.children = []
			self.request = NSURL()
			self.before = nil
			self.after = nil
			return nil
		}

		self.before = before
		self.after = after
		self.children = children
		self.request = request
	}
}

extension RedditListing {
	// Produces the next page after this listing.
	func next() -> Future<RedditListing<Element>, RedditCommunicationError> {
		guard let nextItem = after else {
			return Future(error: RedditCommunicationError.EndOfListing)
		}

		guard let components = NSURLComponents(URL: self.request, resolvingAgainstBaseURL: false) else {
			print("Unable to parse components from URL")
			return Future(error: RedditCommunicationError.RequestError(.InvalidURL))
		}
		if components.queryItems == nil {
			components.queryItems = []
		}
		let afterQuery = RedditConstants.AfterHeader(nextItem)
		components.queryItems!.append(afterQuery.asURLQueryItem())
		guard let requestURL = components.URL else {
			return Future(error: RedditCommunicationError.RequestError(.InvalidURL))
		}

		return DataRequestor.requestHTTP(requestURL, HTTPAdditionalHeaders: KeyValuePair.keyValuePairsAsDictionary(RedditConstants.ModHashHeader))
			.flatMap { data -> Future<RedditListing<Element>, DataRequestor.Error> in
				let json = JSON(data: data)
				if let listing = RedditListing<Element>(json: json, request: requestURL) {
					return Future(value: listing)
				} else {
					return Future(error: DataRequestor.Error.ParseError)
				}
			}.mapError(RedditCommunicationError.RequestError)
	}

	func asyncElementGenerator() -> RedditListingElementGenerator<Element>? {
		return RedditListingElementGenerator<Element>(currentListing: self)
	}
}