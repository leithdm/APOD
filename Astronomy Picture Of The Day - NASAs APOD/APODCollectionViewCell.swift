//
//  APODCollectionViewCell.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 23/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation
import UIKit

class APODCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageTitle: UILabel!
	@IBOutlet weak var moreDetail: UIBarButtonItem!
	@IBOutlet weak var scrollView: UIScrollView!
	
	
	func setup() {
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomImage))
		imageView.addGestureRecognizer(pinch)
		imageView.userInteractionEnabled = true
		scrollView.delegate = self
		setZoomParametersForSize(scrollView.bounds.size)
	}
	
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	
	@IBAction func moreDetailClicked(sender: AnyObject) {
		print("present more detail")
	}
	
	//MARK: zoom image
	
	func zoomImage(gesture: UIPinchGestureRecognizer!) {
		setZoomParametersForSize(scrollView.bounds.size)
	}
	
	func setZoomParametersForSize(scrollViewSize: CGSize) {
		let imageSize = imageView.bounds.size
		let widthScale = scrollViewSize.width / imageSize.width
		let heightScale = scrollViewSize.height / imageSize.height
		let minScale = min(widthScale, heightScale)
		scrollView.minimumZoomScale = minScale
		scrollView.maximumZoomScale = 5.0
		scrollView.zoomScale = minScale
	}
}
