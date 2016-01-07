//
//  ContentViewController.swift
//  pfreddit2
//
//  Created by David Lee on 1/1/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit

protocol ContentViewControllerDataSource: class {
	func contentForContentViewController(contentViewController: ContentViewController) -> ContentType?
}

class ContentViewController: UIViewController {
	weak var dataSource: ContentViewControllerDataSource?
}
