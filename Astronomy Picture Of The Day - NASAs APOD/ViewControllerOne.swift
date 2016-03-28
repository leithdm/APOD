//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
	
	//MARK: properties
	
	var APODarray: [APOD] = []
	weak var delegate: ViewControllerOneDelegate?
	@IBOutlet weak var collectionView: UICollectionView!
	static var APODCount = 0
	let dates = APODClient.sharedInstance.getAllAPODDates()
	var swipeLeft: UISwipeGestureRecognizer!
	var dowloadInProgress = false
	
	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setUpSwipeGestureRecognizer()
		createDummyCells()
	}
	
	func setUpSwipeGestureRecognizer() {
		//add swipe right gesture recognizer
		swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
		swipeLeft.delegate = self
		swipeLeft.numberOfTouchesRequired = 1
		swipeLeft.direction = .Left
		view.addGestureRecognizer(swipeLeft)
	}
	
	func didSwipeLeft(gesture: UISwipeGestureRecognizer) {
		print("swipe left called")
		downloadPhotoProperties()
	}
	
	func createDummyCells() {
		for i in 0..<dates.count {
			let newAPOD = APOD(dateString: dates[i])
			APODarray.append(newAPOD)
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		downloadPhotoProperties()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
	}
	
	
	//MARK: download photo properties
	
	func downloadPhotoProperties() {
		
		dowloadInProgress = true
		
		APODClient.sharedInstance.downloadPhotoProperties(dates[ViewControllerOne.APODCount], completionHandler: { (data, error) in
			
			guard error == nil else {
				print("error")
				return
			}
			
			guard let data: [String: String] = data else {
				print("error")
				return
			}
			
			
			//create an APOD
			let APOD = self.APODarray[ViewControllerOne.APODCount]
			APOD.explanation = data["explanation"]
			APOD.title = data["title"]
			APOD.url = data["url"]
			
			//create an image based on url string
			if APOD.url!.containsString("youtube") {
				APOD.image = UIImage(named: "noPhoto.png")
				dispatch_async(dispatch_get_main_queue()) {
					self.collectionView.reloadData()
				}
			} else {
				let url = NSURL(string: APOD.url!)
				let imageData = NSData(contentsOfURL: url!)
				
				dispatch_async(dispatch_get_main_queue()) {
					APOD.image = UIImage(data: imageData!)
					self.collectionView.reloadData()
				}
			}
			ViewControllerOne.APODCount += 1
			self.dowloadInProgress = false
		})
	}
	
	//MARK: menu button delegate methods
	
	@IBAction func menuButtonTapped(sender: AnyObject) {
		delegate?.viewControllerOneDidTapMenuButton(self)
	}
	
	
	//MARK: collection view
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APODarray.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("APODCollectionViewCell", forIndexPath: indexPath) as! APODCollectionViewCell
		
		cell.setup() //double tap zoom
		let APOD = APODarray[indexPath.item]
		cell.imageView.image = APOD.image
		
		if APOD.dateString != nil {
			self.title = formatDateString(APOD.dateString!)
		}
		cell.imageTitle.text = APOD.title
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		
		//TODO: remove magic numbers
		return CGSize(width: collectionView.frame.size.width - 10, height: collectionView.frame.size.height - 80)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
	{
		return UIEdgeInsetsMake(0, 5, 0, 5)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 10
	}
	
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		if !dowloadInProgress {
		downloadPhotoProperties()
		}
	}
	
	
	//MARK: helper methods
	
	func formatDateString(date: String) -> String?  {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let existingDate = formatter.dateFromString(date)
		let newFormatter = NSDateFormatter()
		newFormatter.dateFormat = "dd MMMM yyyy"
		return newFormatter.stringFromDate(existingDate!)
	}
}
