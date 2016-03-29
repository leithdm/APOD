//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
	
	//MARK: properties
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	var APODarray: [APOD] = []
	var dowloadInProgress = false
	var prevOffset: CGFloat = 0.0
	var noAPODsDownloaded = 1
	var currentAPOD = 1
	static var dates: [String] = APODClient.sharedInstance.getAllAPODDates()
	weak var delegate: ViewControllerOneDelegate?
	
	
	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		createBlankAPODCells()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		downloadPhotoProperties([ViewControllerOne.dates.first!])
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
	}
	
	
	//MARK: scroll view methods
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		
		//determine if swiped left to get a new APOD
		if (self.prevOffset < scrollView.contentOffset.x) {
			if scrollView.contentOffset.x / CGFloat(noAPODsDownloaded) >= collectionView.frame.width {
				noAPODsDownloaded += 1
			}
		}
		self.prevOffset = scrollView.contentOffset.x;
	}
	
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		
		//Debugging
		print("downloads is : \(noAPODsDownloaded)")
		print("current is \(currentAPOD)")
		//
		
		var testDates: [String] = []
		
		for i in currentAPOD..<noAPODsDownloaded {
			testDates.append(ViewControllerOne.dates[i])
		}
		
		//Debugging
		print("new dates to download are \(testDates)")
		//
		
		currentAPOD = noAPODsDownloaded
		downloadPhotoProperties(testDates)
	}
	
	
	//MARK: download photo properties
	
	func downloadPhotoProperties(dates: [String]) {
		
		APODClient.sharedInstance.downloadArrayPhotoProperties(dates, completionHandler: { (data, error) in
			
			guard error == nil else {
				print("error in downloading photo array properties")
				return
			}
			
			guard let data: [String: String] = data else {
				print("error retrieving data")
				return
			}
			
			//using the date as the match criteria, compare the downloaded data with the relevant blank APOD cell
			for APOD in self.APODarray {
				
				//ensures the correct ADOD is paired with correct cell
				if APOD.dateString == data["date"] {
					APOD.explanation = data["explanation"]
					APOD.title = data["title"]
					APOD.url = data["url"]
					
					if !APOD.url!.containsString("http://apod.nasa.gov/") {
						//typically a youtube video
						APOD.image = UIImage(named: "noPhoto.png")
						dispatch_async(dispatch_get_main_queue()) {
							self.collectionView.reloadData()
						}
					} else {
						//create an image based on url string
						let url = NSURL(string: APOD.url!)
						let imageData = NSData(contentsOfURL: url!)
						
						dispatch_async(dispatch_get_main_queue()) {
							APOD.image = UIImage(data: imageData!)
							self.collectionView.reloadData()
						}
					}
					self.dowloadInProgress = false
				}
			}
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
		configureCell(cell, atIndexPath: indexPath)
		return cell
	}
	
	func configureCell(cell: APODCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
		cell.setup()
		let APOD = APODarray[indexPath.item]
		cell.setupActivityIndicator(cell)
		
		if let image = APOD.image {
			cell.activityIndicator.stopAnimating()
			cell.imageView.image = image
			cell.imageTitle.text = APOD.title
			title = formatDateString(APOD.dateString!)

		} else {
			cell.activityIndicator.startAnimating()
			title = ""
			cell.imageView.image = nil
			cell.imageTitle.text = ""

		}
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
	
	
	//MARK: helper methods
	
	//format the date to be in format e.g. 01 January 20xx
	func formatDateString(date: String) -> String?  {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let existingDate = formatter.dateFromString(date)
		let newFormatter = NSDateFormatter()
		newFormatter.dateFormat = "dd MMMM yyyy"
		return newFormatter.stringFromDate(existingDate!)
	}
	
	//create a blank array of APOD cells to populate the collection view. In total ~ 7500 cells created.
	func createBlankAPODCells() {
		for i in 0..<ViewControllerOne.dates.count {
			let newAPOD = APOD(dateString: ViewControllerOne.dates[i])
			print("creating dummy cell \(i)")
			APODarray.append(newAPOD)
		}
	}
	
}
