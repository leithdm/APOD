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
		let tap = UITapGestureRecognizer(target: self, action: "tapImage:")
		tap.numberOfTapsRequired = 2
		scrollView.addGestureRecognizer(tap)
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
	
	func tapImage(gesture: UIPinchGestureRecognizer!) {
		if scrollView.zoomScale > scrollView.minimumZoomScale {
			scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
		} else {
			scrollView.setZoomScale(self.scrollView.maximumZoomScale , animated: true)
		}
	}
	
	func setZoomParametersForSize(scrollViewSize: CGSize) {
//		let imageSize = imageView.bounds.size
//		let widthScale = scrollViewSize.width / imageSize.width
//		let heightScale = scrollViewSize.height / imageSize.height
//		let minScale = min(widthScale, heightScale)
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 5.0
		scrollView.zoomScale = 1.0
	}
}
