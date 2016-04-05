//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

protocol ViewControllerTwoDelegate: class {
	func viewControllerTwoDidTapMenuButton(controller: ViewControllerTwo)
}

class ViewControllerTwo: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

	//MARK: properties

	@IBOutlet weak var collectionView: UICollectionView!

	var APODarray = [APOD]()
	var prevOffset: CGFloat = 0.0
	var noAPODsDownloaded = 1
	var currentAPOD = 1
	weak var delegate: ViewControllerTwoDelegate?


	//MARK: core data

	lazy var sharedContext: NSManagedObjectContext = {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}()

	//file path for saving the number of downloaded images
	var noOfDownloadsFilePath : String {
		let manager = NSFileManager.defaultManager()
		let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
		return url.URLByAppendingPathComponent("noOfDownloads").path!
	}

	//MARK: lifecycle methods

	override func viewDidLoad() {
		super.viewDidLoad()
		title = formatDateStringForTitle(ViewControllerOne.dates[0])
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		restoreNoOfDownloads()
		APODarray = fetchAllAPODS()
		collectionView.reloadData()
		//TODO: remove magic number
		getImages(8)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
	}

	//MARK: core data
	func fetchAllAPODS() -> [APOD] {
		let fetchRequest = NSFetchRequest(entityName: "APOD")

		do {
		 return try sharedContext.executeFetchRequest(fetchRequest) as! [APOD]
		} catch {
			return [APOD]()
		}
	}


	//MARK: downloading new photo properties when scrolling

//	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//		getImages()
//	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		getImages()
	}
	
	func getImages(max: Int = 0) {
		var max = max
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			if index.item > max {
				max = index.item
			}
		}
		print("max: \(max)")
		print("noAPODsDownloaded: \(noAPODsDownloaded)")

		title = formatDateStringForTitle(ViewControllerOne.dates[max])

		if noAPODsDownloaded < max {
			var datesToDownload: [String] = []
			for i in noAPODsDownloaded...max {
				datesToDownload.append(ViewControllerOne.dates[i])
			}
			
			print("new dates to download: \(datesToDownload)")
			
			getPhotoProperties(datesToDownload)
			noAPODsDownloaded = max
			currentAPOD = noAPODsDownloaded
			saveNoOfDownloads()
			title = formatDateStringForTitle(ViewControllerOne.dates[max])
		}
	}

	//MARK: download photo properties

	func getPhotoProperties(dates: [String]) {

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

				//ensures the correct APOD is paired with correct cell
				if APOD.dateString == data["date"] {
					APOD.explanation = data["explanation"]
					APOD.title = data["title"]
					APOD.url = data["url"]

					if !APOD.url!.containsString("http://apod.nasa.gov/") {
						//typically a video cannot be displayed as an image
						self.performUIUpdatesOnMain({
							APOD.image = UIImage(named: "noPhoto")
							self.collectionView.reloadData()
							CoreDataStackManager.sharedInstance.saveContext()
						})
					} else {
						//create an image based on url string
						let url = NSURL(string: APOD.url!)
						let imageData = NSData(contentsOfURL: url!)
						self.performUIUpdatesOnMain({ 
							APOD.image = UIImage(data: imageData!)
							self.collectionView.reloadData()
							CoreDataStackManager.sharedInstance.saveContext()
						})
					}
					return
				}
			}
		})
	}

	//MARK: menu button delegate methods

	@IBAction func menuButtonTapped(sender: AnyObject) {
		delegate?.viewControllerTwoDidTapMenuButton(self)
	}


	//MARK: collection view

	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APODarray.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryAPODCollectionViewCell", forIndexPath: indexPath) as! GalleryAPODCollectionViewCell
		configureCell(cell, atIndexPath: indexPath)
		return cell
	}

	func configureCell(cell: GalleryAPODCollectionViewCell, atIndexPath indexPath: NSIndexPath) {

		let APOD = APODarray[indexPath.item]
		cell.setupActivityIndicator(cell)



		//if the image has already been downloaded and is in the Documents directory
		if let image = APOD.image {
			cell.imageInfoView.hidden = false
			cell.activityIndicator.stopAnimating()
			cell.imageView.image = image
			cell.imageDate.text = formatDateString(APOD.dateString!)
			cell.imageTitle.text = APOD.title
			if APOD.favorite == true {
				cell.favoriteImage.hidden = false
			} else {
				cell.favoriteImage.hidden = true
			}
		} else { //download from the remote server
			cell.imageInfoView.hidden = true
			cell.activityIndicator.startAnimating()
			cell.imageView.image = nil
			cell.imageTitle.text = ""
			cell.imageDate.text = ""
			cell.favoriteImage.hidden = true
		}
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		//TODO: remove magic numbers
		return CGSize(width: collectionView.frame.size.width/2 - 10, height: collectionView.frame.size.width/2 - 10)
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
	{
		return UIEdgeInsetsMake(0, 5, 0, 5)
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 10
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let vcOne = storyboard!.instantiateViewControllerWithIdentifier("ViewControllerOne") as! ViewControllerOne
		vcOne.apodIndex = indexPath
		navigationController?.pushViewController(vcOne, animated: true)
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

	func formatDateStringForTitle(date: String) -> String?  {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let existingDate = formatter.dateFromString(date)
		let newFormatter = NSDateFormatter()
		newFormatter.dateFormat = "MMMM yyyy"
		return newFormatter.stringFromDate(existingDate!)
	}

	//create a blank array of APOD cells to populate the collection view. In total ~ 7500 cells created.
	func createBlankAPODCells() {
		for i in APODarray.count..<100 {
			let newAPOD = APOD(dateString: ViewControllerOne.dates[i], context: self.sharedContext)
			APODarray.append(newAPOD)
			collectionView.reloadData()
			CoreDataStackManager.sharedInstance.saveContext()
		}
	}


	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}

	//MARK: save and restore number of downloads

	func saveNoOfDownloads() {
		let dictionary = [
			"noAPODsDownloaded" : noAPODsDownloaded,
			"currentAPOD"		: currentAPOD
		]
		NSKeyedArchiver.archiveRootObject(dictionary, toFile: noOfDownloadsFilePath)
	}

	func restoreNoOfDownloads() {
		if let dictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(noOfDownloadsFilePath) as? [String : AnyObject] {
			noAPODsDownloaded = dictionary["noAPODsDownloaded"] as! Int
			currentAPOD = dictionary["currentAPOD"] as! Int
		}
	}	
}





