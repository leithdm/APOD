//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import CoreData

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, MoreOptionsViewControllerDelegate, APODCollectionViewCellDelegate {

	//MARK: Constants

	struct APODConstants {
		static let EntityName = "APOD"
		static let APIURL = "http://apod.nasa.gov/"
		static let ReusableCellIdentifier = "APODCollectionViewCell"
		static let BlanksAPODs = 16
		static let APIWebsiteURL = "http://apod.nasa.gov/apod/ap"
		static let HTML = ".html"
	}

	//MARK: properties

	var dates: [String] = APODClient.sharedInstance.getAllAPODDates()
	var APODarray = [APOD]()
	weak var delegate: ViewControllerOneDelegate?
	var apodIndex: NSIndexPath?
	var currentIndexPath: NSIndexPath?

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var barButton: UIBarButtonItem!
	@IBOutlet weak var moreOptionsView: UIView!
	@IBOutlet weak var moreOptionsContainerView: UIView!
	@IBOutlet weak var moreOptionsBarButtonItem: UIBarButtonItem!

	//MARK: lifecycle methods

	override func viewDidLoad() {
		super.viewDidLoad()
		setupMoreOptionsView()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		APODarray = fetchAllAPODS()

		//first instance of running the app
		if APODarray.count == 0 {
			createBlankAPODCells()
			getPhotoProperties([dates.first!])
		} else {
			//get any APODs not downloaded from the server
			let dates = getMissingAPODDates()
			var datesToCheck: [String] = []
			for date in dates  {
				if date != APODarray.first?.dateString {
					datesToCheck.append(date)
				}
			}

			if datesToCheck.count != 0 {
				insertBlankAPODCells(datesToCheck.count)
				getPhotoProperties([dates.first!])
			}
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)

		if let index = apodIndex {
			collectionView.scrollToItemAtIndexPath(index, atScrollPosition: .None, animated: false)
			barButton.image = UIImage(named: "leftArrow")
		} else { //otherwise always scroll to the most recent APOD
			let index = NSIndexPath(forRow: 0, inSection: 0)
			collectionView.scrollToItemAtIndexPath(index, atScrollPosition: .None, animated: false)
		}
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

	//MARK: scrolling methods

	func scrollViewDidScroll(scrollView: UIScrollView) {
		var max = 0

		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			if max < index.row {
				max = index.row
			}
		}
		title = formatDateString(dates[max])
	}

	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		var max = 0
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			if max < index.row {
				max = index.row
			}
		}

		if max == APODarray.count-1 {
			createBlankAPODCells()
		}
		getImages()
	}

	//MARK: determine what APODs have not been downloaded yet

	func getMissingAPODDates() -> [String] {
		var returnArray = [String]()
		let originDateString = APODarray.first?.dateString
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"

		let dateValue1 = dateFormatter.dateFromString(originDateString!) as NSDate!
		let dateValue2 = NSDate() //todays date
		let calendar = NSCalendar.currentCalendar()
		let flags: NSCalendarUnit = NSCalendarUnit.Day

		let components = calendar.components(flags, fromDate: dateValue1, toDate: dateValue2, options: NSCalendarOptions.MatchStrictly)

		for index in 0...components.day {
			let components = NSDateComponents()
			components.day = index
			let newDate = calendar.dateByAddingComponents(components, toDate: dateValue1, options: NSCalendarOptions.MatchStrictly)!
			returnArray.insert(dateFormatter.stringFromDate(newDate), atIndex: 0)
		}
		return returnArray
	}


	//MARK: download photo properties

	func getImages() {
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			let apod = APODarray[index.item]
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

					//a video cannot be displayed as an image
					if !APOD.url!.containsString(APODConstants.APIURL) {
						dispatch_async(dispatch_get_main_queue()) {
							APOD.image = UIImage(named: "noPhoto")
							self.collectionView.reloadData()
							CoreDataStackManager.sharedInstance.saveContext()
						}
					} else {
						//create an image based on url string
						let url = NSURL(string: APOD.url!)
						let imageData = NSData(contentsOfURL: url!)

						dispatch_async(dispatch_get_main_queue()) {
							APOD.image = UIImage(data: imageData!)
							self.collectionView.reloadData()
							CoreDataStackManager.sharedInstance.saveContext()
						}
					}
					return
				}
			}
		})
	}

	@IBAction func menuButtonTapped(sender: AnyObject) {
		if let _ = apodIndex {
			navigationController?.popToRootViewControllerAnimated(true)
		} else {
			delegate?.viewControllerOneDidTapMenuButton(self)
		}
	}

	@IBAction func moreOptionsButtonClicked(sender: UIBarButtonItem) {
		showMoreOptionsDetailView()
	}


	//MARK: collection view

	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APODarray.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(APODConstants.ReusableCellIdentifier, forIndexPath: indexPath) as! APODCollectionViewCell
		currentIndexPath = indexPath
		configureCell(cell, atIndexPath: indexPath)
		return cell
	}


	func configureCell(cell: APODCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
		cell.setup()
		cell.delegate = self

		let APOD = APODarray[indexPath.item]
		cell.setupActivityIndicator(cell)

		//if the image has already been downloaded and is in the Documents directory
		if let image = APOD.image {

			if !APOD.url!.containsString(APODConstants.APIURL)  {
				cell.isAVideoText.hidden = false
				cell.goToWebSite.hidden = false
			}

			cell.titleBottomToolbar.hidden = false
			cell.loadingImageText.hidden = true
			cell.activityIndicator.stopAnimating()
			cell.imageView.image = image
			cell.imageTitle.text = APOD.title
			cell.explanation = APOD.explanation
			title = formatDateString(APOD.dateString!)

			NSNotificationCenter.defaultCenter().postNotificationName("favoriteStatus", object: nil, userInfo: ["isAlreadyFavorite" : APOD.favorite])

		} else { //download from the remote serve
			cell.titleBottomToolbar.hidden = true
			cell.loadingImageText.hidden = false
			cell.activityIndicator.startAnimating()
			cell.imageView.image = nil
			cell.imageTitle.text = ""
		}
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.size.width - 10, height: collectionView.frame.size.height - 80)
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 5, 0, 5)
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 10
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "MoreOptionsViewController" {
			let vc = segue.destinationViewController as! MoreOptionsViewController
			vc.delegate = self
		}
	}

	//MARK: moreOptions methods (add to favorites, share)

	func moreOptionsViewControllerSelectShare(controller: MoreOptionsViewController) {
		let apod = APODarray[currentIndexPath!.row]
		let link = apod.url
		let activityVC = UIActivityViewController(activityItems: [link!, apod.image!], applicationActivities: .None)
		presentViewController(activityVC, animated: true, completion: nil)
	}

	func moreOptionsViewControllerSelectCancel(controller: MoreOptionsViewController) {
		hideMoreOptionsView()
	}

	func showMoreOptionsDetailView() {
		moreOptionsBarButtonItem.enabled = false
		//Animate the detail view to appear on screen
		moreOptionsContainerView.center.y += view.bounds.height
		UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in
			self.moreOptionsContainerView.center.y -= self.view.bounds.height
			self.moreOptionsView.alpha = 0.7
			}, completion: nil)
		moreOptionsContainerView.hidden = false
	}

	func hideMoreOptionsView() {
		UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: { () -> Void in
			self.moreOptionsContainerView.center.y += self.view.bounds.height
			self.moreOptionsView.alpha = 0.0
			}, completion: { _ in
				self.moreOptionsContainerView.center.y -= self.view.bounds.height
				self.moreOptionsContainerView.hidden = true
				self.moreOptionsBarButtonItem.enabled = true
		})
	}

	func moreOptionsViewControllerSelectFavorite(controller: MoreOptionsViewController, removeFromFavorites: Bool) {
		let apod = APODarray[currentIndexPath!.item]

		if removeFromFavorites {
			apod.favorite = false
		} else {
			apod.favorite = true
		}
		performUIUpdatesOnMain {
			CoreDataStackManager.sharedInstance.saveContext()
			self.collectionView.reloadData()
		}
	}

	func setupMoreOptionsView() {
		moreOptionsView.alpha = 0.0
		moreOptionsContainerView.hidden = true
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

	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}

	func APODCollectionViewCellDelegateGoToWebsite(controller: APODCollectionViewCell) {
		let apod = APODarray[currentIndexPath!.row]
		let URL = APODConstants.APIWebsiteURL + convertDateForWebsite(apod.dateString!) + APODConstants.HTML
		let app = UIApplication.sharedApplication()
		if let url = NSURL(string: URL) {
			if app.canOpenURL(url) {
				app.openURL(url)
			}
		}
	}

	//date must be of the format YYMMDD e.g. "160421" in order to link to the APOD website
	func convertDateForWebsite(date: String) -> String {
		let newDate: NSString = date.stringByReplacingOccurrencesOfString("-", withString: "")
		return newDate.substringWithRange(NSRange(location: 2, length: newDate.length-2)) as String
	}

	//create a blank array of APOD cells to populate the collection view
	func createBlankAPODCells() {
		for i in 0..<APODConstants.BlanksAPODs {
			let newAPOD = APOD(dateString: dates[i], context: self.sharedContext)
			APODarray.append(newAPOD)
			CoreDataStackManager.sharedInstance.saveContext()
		}
	}

	func insertBlankAPODCells(number: Int) {
		for i in 0..<number {
			let newAPOD = APOD(dateString: dates[i], context: self.sharedContext)
			APODarray.insert(newAPOD, atIndex: 0)
			CoreDataStackManager.sharedInstance.saveContext()
		}
	}
}
