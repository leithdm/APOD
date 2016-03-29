//
//  APODCollectionViewCell.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 23/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation
import UIKit

class APODCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageTitle: UILabel!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	var explanation: String?

	/*
	var customTextView: UIView!
	var textInCustomView: UITextView!
	*/

	@IBOutlet weak var detailView: UIView!
	@IBOutlet weak var detailTextView: UITextView!
	@IBOutlet weak var detailToolbar: UIToolbar!
	@IBOutlet weak var detailLabel: UILabel!


	func setup() {
		//add tap getsture recognizer
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapImage))
		tap.numberOfTapsRequired = 2
		scrollView.addGestureRecognizer(tap)
		imageView.userInteractionEnabled = true
		scrollView.delegate = self
		setZoomParametersForSize(scrollView.bounds.size)
		hideDetailView()
	}

	func hideDetailView() {
		detailView.hidden = true
		detailTextView.hidden = true
		detailToolbar.hidden = true
		detailLabel.hidden = true
	}

	func showDetailView() {
		detailView.hidden = false
		detailTextView.hidden = false
		detailToolbar.hidden = false
		detailLabel.hidden = false
	}
	
	func setupActivityIndicator(cell: APODCollectionViewCell) {
		cell.activityIndicator.startAnimating()
		cell.activityIndicator.hidesWhenStopped = true
		cell.activityIndicator.activityIndicatorViewStyle = .WhiteLarge
	}
	
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	@IBAction func showMoreDetail(sender: UIBarButtonItem) {
		showDetailView()
		detailTextView.text = explanation
	}

	@IBAction func closeMoreDetail(sender: UIBarButtonItem) {
		hideDetailView()
	}


	@IBAction func moreDetailClicked(sender: UIBarButtonItem) {
		/*
		customTextView = UIView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
		let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissCustomTextView))
		gesture.direction = .Down
		customTextView.addGestureRecognizer(gesture)
		
		textInCustomView = UITextView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
		textInCustomView.editable = false
		moreDetail.enabled = false
		textInCustomView.text = explanation
		
		customTextView.addSubview(textInCustomView)
		scrollView.addSubview(customTextView)
		*/

		print("clicked")


	}

	/*
	//TODO: not being called
	func scrollViewDidScroll(scrollView: UIScrollView) {
		print("scroll view called")
		if customTextView != nil {
			customTextView.removeFromSuperview()
			moreDetail.enabled = true
		}
	}
	*/
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		print("end decelerating called")
	}
	
	/*
	func dismissCustomTextView(gesture: UISwipeGestureRecognizer) {
		moreDetail.enabled = true
		customTextView.removeFromSuperview()
	}
	*/
	
	//MARK: zoom image
	
	func tapImage(gesture: UIPinchGestureRecognizer!) {
		if scrollView.zoomScale > scrollView.minimumZoomScale {
			scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
		} else {
			scrollView.setZoomScale(self.scrollView.maximumZoomScale , animated: true)
		}
	}
	
	func setZoomParametersForSize(scrollViewSize: CGSize) {
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 5.0
		scrollView.zoomScale = 1.0
	}
}
