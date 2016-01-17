//
//  AppDelegate.swift
//  pfreddit2
//
//  Created by David Lee on 12/21/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit
import BrightFutures

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Setup initial view controller.
		let graphNavigationController = GraphNavigationViewController()
		downloadStories(15).onSuccess { _ in
			SharedContentGraph.pickNodes(1, filter: nil).onSuccess { nodes in
				graphNavigationController.pushNodeViewForNode(nodes.first!, animated: false)
			}
		}

		// Show view controller in window.
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.rootViewController = graphNavigationController
		window?.makeKeyAndVisible()
		
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


// Temporary helpers for grabbing stories / making links
extension AppDelegate {
	func downloadStories(downloadCount: Int = 50) -> Future<[ContentNode], ContentServiceError> {
		let redditService = RedditContentService()
		return redditService.prefetchNodes(30).flatMap { response -> Future<[ContentNode], ContentServiceError> in
			return response.sequence().flatMap { SharedContentGraph.writeNodes($0).mapError(ContentServiceError.External) }
		}
	}
}