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
	@IBOutlet weak var titleBottomToolbar: UIToolbar!
	@IBOutlet weak var detailView: UIView! //explanation text view
	@IBOutlet weak var detailTextView: UITextView! //explanation textView
	@IBOutlet var detailToolbarButton: UIBarButtonItem!
	var detailViewVisible: Bool = false //explanation text visibility
	var explanation: String?

	func setup() {
		
		scrollView.delegate = self
		setZoomParametersForSize(scrollView.bounds.size)
		
		detailTextView.scrollRangeToVisible(NSMakeRange(0, 0))
		
		//tap getsture recognizer to zoom image
		let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(tapImage))
		scrollViewTap.numberOfTapsRequired = 2
		scrollView.addGestureRecognizer(scrollViewTap)

		//initial detail view setup
		initialDetailViewSetup()
		
		//tap gesture for toolBar
		let toolbarTap = UITapGestureRecognizer(target: self, action: #selector(tapToolBar))
		toolbarTap.numberOfTapsRequired = 1
		titleBottomToolbar.addGestureRecognizer(toolbarTap)
		
		//swipe gesture for scrollview
		let scrollViewSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpOnView))
		scrollViewSwipeUp.direction = .Up
		scrollView.addGestureRecognizer(scrollViewSwipeUp)
		
		//swipe gestures for toolBar
		let toolBarSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpOnView))
		toolBarSwipeUp.direction = .Up
		titleBottomToolbar.addGestureRecognizer(toolBarSwipeUp)
		
		let toolBarSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownOnView))
		toolBarSwipeDown.direction = .Down
		titleBottomToolbar.addGestureRecognizer(toolBarSwipeDown)
	}
	
	func swipeUpOnView(gesture: UISwipeGestureRecognizer!) {
		if !detailViewVisible {
			showDetailView()
		}
	}
	
	func swipeDownOnView(gesture: UISwipeGestureRecognizer!) {
		if detailViewVisible {
			hideDetailView()
		}
	}

	func initialDetailViewSetup() {
		detailToolbarButton.image = UIImage(named: "upArrow")
		detailViewVisible = false
		detailView.hidden = true
		detailTextView.hidden = true
		imageTitle.hidden = false
	}
	
	func hideDetailView() {
		UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: { () -> Void in
			self.detailView.center.y += self.scrollView.bounds.height
			}, completion: { _ in
			self.initialDetailViewSetup()
			self.detailView.center.y -= self.scrollView.bounds.height
		})
	}

	func showDetailView() {
		
		if scrollView.zoomScale > scrollView.minimumZoomScale {
			scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
		}
		
		//Animate the detail view to appear on screen
		detailView.center.y += scrollView.bounds.height
		UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in
			self.detailView.center.y -= self.scrollView.bounds.height
			}, completion: nil)
		
		detailViewVisible = true
		detailView.hidden = false
		detailTextView.hidden = false
		detailTextView.text = explanation
		detailToolbarButton.image = UIImage(named: "downArrow")
		
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
		toolBarStatus()
	}

	func tapToolBar(gesture: UITapGestureRecognizer!) {
		toolBarStatus()
	}
	
	func toolBarStatus() {
		if detailViewVisible {
			hideDetailView()
		} else {
			if scrollView.zoomScale > scrollView.minimumZoomScale {
				scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
			}
			showDetailView()
		}
	}

	//MARK: zoom image
	
	func tapImage(gesture: UITapGestureRecognizer!) {
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
