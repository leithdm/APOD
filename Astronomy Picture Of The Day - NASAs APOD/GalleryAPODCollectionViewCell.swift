//
//  APODCollectionViewCell.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 23/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation
import UIKit

class GalleryAPODCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageDate: UILabel!
	@IBOutlet weak var imageTitle: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageInfoView: UIView!
	@IBOutlet weak var favoriteImage: UIImageView!


	func setupActivityIndicator(cell: GalleryAPODCollectionViewCell) {
		cell.activityIndicator.startAnimating()
		cell.activityIndicator.hidesWhenStopped = true
		cell.activityIndicator.activityIndicatorViewStyle = .WhiteLarge
	}
}
