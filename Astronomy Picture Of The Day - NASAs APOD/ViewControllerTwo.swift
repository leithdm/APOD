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

	//MARK: Constants

	struct APODConstants {
		static let EntityName = "APOD"
		static let APIURL = "http://apod.nasa.gov/"
		static let ReusableCellIdentifier = "GalleryAPODCollectionViewCell"
		static let BlanksAPODs = 64
	}

	//MARK: properties

	var APODarray = [APOD]()
	weak var delegate: ViewControllerTwoDelegate?
	var dates: [String] = APODClient.sharedInstance.getAllAPODDates()
	@IBOutlet weak var collectionView: UICollectionView!

	//MARK: lifecycle methods

	override func viewDidLoad() {
		super.viewDidLoad()
		title = formatDateStringForTitle(dates[0])
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		APODarray = fetchAllAPODS()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		getImages()
	}

	//MARK: core data

	lazy var sharedContext: NSManagedObjectContext = {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}()

	func fetchAllAPODS() -> [APOD] {
		let fetchRequest = NSFetchRequest(entityName: APODConstants.EntityName)

		do {
		 return try sharedContext.executeFetchRequest(fetchRequest) as! [APOD]
		} catch {
			return [APOD]()
		}
	}


	//MARK: downloading photo properties when scrolling

	func scrollViewDidScroll(scrollView: UIScrollView) {
		var max = 0
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			if max < index.row {
				max = index.row
			}
		}
		title = formatDateStringForTitle(dates[max])
	}

	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {

		var max = 0

		//get the highest index of visible cells on screen
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			if max < index.row {
				max = index.row
			}
		}

		//dynamically populate collection view with blank cells
		if max == APODarray.count-1 {
			createBlankAPODCells()
		}
		getImages()
	}


	//MARK: download photo properties

	func getImages() {
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			let apod = APODarray[index.row]
			if apod.image == nil {
				getPhotoProperties([dates[index.row]])
			}
		}
	}

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

					if !APOD.url!.containsString(APODConstants.APIURL) {
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
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(APODConstants.ReusableCellIdentifier, forIndexPath: indexPath) as! GalleryAPODCollectionViewCell
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
			if APOD.favorite {
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

		let apod = APODarray[indexPath.row]

		//prevents an image from being clicked if not downloaded yet
		if apod.image == nil {
			return
		}

		let vcOne = storyboard!.instantiateViewControllerWithIdentifier("ViewControllerOne") as! ViewControllerOne
		vcOne.apodIndex = indexPath
		navigationController?.pushViewController(vcOne, animated: true)
	}

	//MARK: helper methods

	//format the date to be in format e.g. 01 January 2016
	func formatDateString(date: String) -> String?  {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let existingDate = formatter.dateFromString(date)
		let newFormatter = NSDateFormatter()
		newFormatter.dateFormat = "dd MMMM yyyy"
		return newFormatter.stringFromDate(existingDate!)
	}

	//title is of format e.g. January 2016
	func formatDateStringForTitle(date: String) -> String?  {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let existingDate = formatter.dateFromString(date)
		let newFormatter = NSDateFormatter()
		newFormatter.dateFormat = "MMMM yyyy"
		return newFormatter.stringFromDate(existingDate!)
	}


	//create a blank array of APOD cells to populate the collection view
	func createBlankAPODCells() {
		for _ in 0..<APODConstants.BlanksAPODs {
			let newAPOD = APOD(dateString: dates[APODarray.count], context: self.sharedContext)
			APODarray.append(newAPOD)
			CoreDataStackManager.sharedInstance.saveContext()
		}
	}

	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}
}