//
//  AppDelegate.swift
//  pfreddit2
//
//  Created by David Lee on 12/21/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.rootViewController = GraphNavigationViewController()
		window?.makeKeyAndVisible()
		guard let graphNavigationController = window?.rootViewController as? GraphNavigationViewController else {
			return false
		}

		downloadStories(25) {
			SharedContentGraph.pickNodes(1).onSuccess { nodes in
				graphNavigationController.pushNodeViewForNode(nodes.first!)
			}
		}
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}


// Some helpers for grabbing stories / making links
extension AppDelegate {
	func downloadStories(downloadCount: Int = 25, callback: () -> Void) {
		func readNodePage(alreadyDownloaded: Int)(listing: RedditListing<RedditLink>) {
			if listing.children.count + alreadyDownloaded >= downloadCount {
				let numberToRead = downloadCount - alreadyDownloaded
				let childrenSliceToRead = listing.children.prefix(numberToRead)
				SharedContentGraph.writeNodes(childrenSliceToRead.map(ContentNode.init))
				callback()
				// exit recursion
				return
			} else {
				SharedContentGraph.writeNodes(listing.children.map(ContentNode.init))
				listing.next().onSuccess(callback: readNodePage(alreadyDownloaded + listing.children.count))
			}
		}

		RedditCommunicator.loadStoriesFromSubreddit("all")
			.onSuccess(callback: readNodePage(0))
			.onFailure { print("ERROR:", $0) }
	}

	func makeArbitraryLinks(callback: () -> Void) {
		SharedContentGraph.pickNodes(25).map { nodeSet in
			nodeSet.reduce([]) { (var acc, elm) -> [ContentEdge] in
				if let last = acc.last {
					acc.append(ContentEdge(sourceNode: last.destination, destinationNode: elm))
				} else {
					acc.append(ContentEdge(sourceNode: elm, destinationNode: elm))
				}
				return acc
			}
		}
	}
}