//
//  NodePreviewCell.swift
//  pfreddit2
//
//  Created by David Lee on 12/23/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class NodePreviewCell: UICollectionViewCell {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var thumbnailView: UIImageView!

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		self.backgroundView = UIView()
		self.backgroundView?.backgroundColor = UIColor(white: 0.5, alpha: 0.7)

		self.selectedBackgroundView = UIView()
		self.selectedBackgroundView?.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
	}

	override func prepareForReuse() {
		thumbnailView.image = nil
		titleLabel.text = nil
	}
}
