//
//  NodePreviewCell.swift
//  pfreddit2
//
//  Created by David Lee on 12/23/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class NodePreviewCell: UITableViewCell {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var thumbnailView: UIImageView! {
		didSet {
			thumbnailView.contentMode = .ScaleAspectFill
			thumbnailView.clipsToBounds = true
		}
	}

	override func prepareForReuse() {
		thumbnailView.image = nil
		titleLabel.text = nil
	}
}
