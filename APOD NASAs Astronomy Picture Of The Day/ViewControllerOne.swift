//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, MoreOptionsViewControllerDelegate, APODCollectionViewCellDelegate {
	
	//MARK: constants
	
	struct APODConstants {
		static let EntityName				= "APOD"
		static let APIURL					= "http://apod.nasa.gov/"
		static let ReusableCellIdentifier	= "APODCollectionViewCell"
		static let APIWebsiteURL			= "http://apod.nasa.gov/apod/ap"
		static let HTML						= ".html"
		static let AlertTitleConnection		= "Connection offline"
		static let AlertMessageConnection	= "Please check your internet connection"
		static let AlertActionTitle			= "Ok"
		static let InitialDelay				= 8.0
	}
	
	//MARK: properties
	
	var dates: [String] = APODClient.sharedInstance.getAllAPODDates()
	var datesTesting: [String] = APODClient.sharedInstance.getAllAPODDatesTesting()
	var APODarray = [APOD]()
	weak var delegate: ViewControllerOneDelegate?
	var apodIndex: NSIndexPath?
	var currentIndexPath: NSIndexPath?
	var isConnectedToNetwork: Bool =  true
	let messages = ["Initializing..", "Configuring Database..", "Caching Image.."]
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var barButton: UIBarButtonItem!
	@IBOutlet weak var moreOptionsView: UIView!
	@IBOutlet weak var moreOptionsContainerView: UIView!
	@IBOutlet weak var moreOptionsBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var loadingNotification: UILabel!
	

	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("DEBUG: viewDidLoad on VC1 called")
		setupMoreOptionsView()
		loadingNotification.alpha = 0.0
	}
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		print("DEBUG: viewWillAppear on VC1 called")
		
		//compute the latest dates
		dates = APODClient.sharedInstance.getAllAPODDates()
		
		collectionView.reloadData()
		APODarray = fetchAllAPODS()

		if APODarray.count == 0 {
			setupFirstInitialization()
		}
		else {
			getNewAPODS()
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		print("DEBUG: viewDidLayoutSubview on VC1 called")

		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
		
		//if we are navigating to this view from the galleryImage view
		if let index = apodIndex {
		print("DEBUG: scrolling to item at indexPath")
			APODarray = fetchAllAPODS()
			collectionView.scrollToItemAtIndexPath(index, atScrollPosition: .None, animated: false)
			barButton.image = UIImage(named: "leftArrow")
			collectionView.reloadData() //this is NOT necessary since it it called in viewWillAppear
		} else { //otherwise always scroll to the most recent APOD
			print("DEBUG: scrolling to row0, section0")
			let index = NSIndexPath(forRow: 0, inSection: 0)
			collectionView.scrollToItemAtIndexPath(index, atScrollPosition: .None, animated: false)
		}
	}
	
	//MARK: initialization methods when app starts
	
	//first instance of app being used
	func setupFirstInitialization() {
		view.userInteractionEnabled = false
		barButton.enabled = false
		moreOptionsBarButtonItem.enabled = false
		animateLoadingNotification(0)
		createBlankAPODCells()
		
		//delay the downloading of first APOD so user doesnt decide to try interact with app
		delay(APODConstants.InitialDelay, closure: {
			//TESTING: replace dates array with datesTesting
//			let dates = APODClient.sharedInstance.getAllAPODDates()
			self.getPhotoProperties([self.dates.first!])
			self.view.userInteractionEnabled = true
			self.barButton.enabled = true
			self.moreOptionsBarButtonItem.enabled = true
		})
	}
	
	//get any new APODS not downloaded from the server
	func getNewAPODS() {
		let downloadQueue = dispatch_queue_create("download", nil)
		dispatch_async(downloadQueue) { () -> Void in
			let dates = self.getMissingAPODDates()
			print("DEBUG: the missing dates (including today) are: \(dates)")
			var datesToCheck: [String] = []
			for date in dates  {
				//modify array so it does not include the "current" most recent date i.e. this will not match the servers most current date
				if date != self.APODarray.first?.dateString {
					datesToCheck.append(date)
				}
			}
			
			if datesToCheck.count != 0 {
				print("DEBUG: new apod cells will be created for these dates: \(datesToCheck)")
				self.insertBlankAPODCells(datesToCheck.count)
				self.performUIUpdatesOnMain({
					self.APODarray = self.fetchAllAPODS()
					/*
					* Version 1.2 - The dates were not being updated as it was not really a computed property
					* Version 1.0 and 1.1 used the global variable dates, as opposed to the local one.
					* This meant that new dates were never actually created.
					*/
//					let dates = APODClient.sharedInstance.getAllAPODDates()
					self.getPhotoProperties([self.dates.first!])
				})
			}
		}
	}
	
	//MARK: core data
	
	lazy var sharedContext: NSManagedObjectContext = {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}()
	
	lazy var backgroundSharedContext: NSManagedObjectContext = {
		return CoreDataStackManager.sharedInstance.backgroundManagedObjectContext
	}()
	
	func fetchAllAPODS() -> [APOD] {
		let fetchRequest = NSFetchRequest(entityName: APODConstants.EntityName)
		let sectionSortDescriptor = NSSortDescriptor(key: "dateId", ascending: false)
		let sortDescriptors = [sectionSortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		do {
		 return try sharedContext.executeFetchRequest(fetchRequest) as! [APOD]
		} catch {
			return [APOD]()
		}
	}
	
	//MARK: scrolling methods
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		if APODarray.count < 0 {
			return
		}
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		var max = 0
		
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			if max < index.row {
				max = index.row
			}
		}
		title = formatDateString(self.dates[max])
	}
	
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
				getPhotoProperties([self.dates[index.row]])
			}
		}
	}
	
	func getPhotoProperties(dates: [String]) {
		
		APODClient.sharedInstance.downloadArrayPhotoProperties(dates, completionHandler: { (data, error) in
			
			guard error == nil else {
				self.isConnectedToNetwork = false
				self.performUIUpdatesOnMain({
					self.collectionView.reloadData()
				})
				return
			}
			
			guard let data: [String: String] = data else {
				return
			}
			
			self.isConnectedToNetwork = true
			
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
						if let stringURL = APOD.url {
							if let url = NSURL(string: stringURL) {
								if let imageData = NSData(contentsOfURL: url) {
									
									dispatch_async(dispatch_get_main_queue()) {
										APOD.image = UIImage(data: imageData)
										self.collectionView.reloadData()
										CoreDataStackManager.sharedInstance.saveContext()
									}
								} else {
									self.isConnectedToNetwork = false
									self.showAlertViewController(APODConstants.AlertTitleConnection, message: APODConstants.AlertMessageConnection)
								}
							} else {
								self.isConnectedToNetwork = false
								self.showAlertViewController(APODConstants.AlertTitleConnection, message: APODConstants.AlertMessageConnection)
							}
						} else {
							self.isConnectedToNetwork = false
							self.showAlertViewController(APODConstants.AlertTitleConnection, message: APODConstants.AlertMessageConnection)
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
			if let url = APOD.url {
				if !url.containsString(APODConstants.APIURL) {
					cell.isAVideoText.hidden = false
					cell.goToWebSite.hidden = false
				}
			}
			
			cell.titleBottomToolbar.hidden = false
			cell.loadingImageText.hidden = true
			cell.activityIndicator.stopAnimating()
			cell.imageView.image = image
			cell.imageTitle.text = APOD.title
			cell.explanation = APOD.explanation
			title = formatDateString(APOD.dateString!)
			NSNotificationCenter.defaultCenter().postNotificationName("favoriteStatus", object: nil, userInfo: ["isAlreadyFavorite" : APOD.favorite])
		} else {
			//download from the remote serve
			
			if !isConnectedToNetwork {
				moreOptionsBarButtonItem.enabled = false
				cell.activityIndicator.stopAnimating()
				cell.imageView.image = UIImage(named: "noPhoto")
				cell.titleBottomToolbar.hidden = true
				cell.loadingImageText.hidden = true
				cell.imageTitle.text = APODConstants.AlertTitleConnection
				return
			}
			
			cell.titleBottomToolbar.hidden = true
			cell.loadingImageText.hidden = false
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
	
	//delay function
	func delay(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
	
	//animated loading notifications when initialize the app for first time
	func animateLoadingNotification(index: Int) {
		self.loadingNotification.text = self.messages[index]
		
		UIView.animateWithDuration(0.7, delay: 0.0, options: [], animations: { () -> Void in
			self.loadingNotification.alpha = 1.0
			}, completion: { _ in
				UIView.animateWithDuration(1.0, delay: 0.3, options: [], animations: {
					self.loadingNotification.alpha = 0.0
					}, completion: {_ in
						self.delay(1.0, closure: {
							if index < self.messages.count-1 {
								self.animateLoadingNotification(index+1)
							}
						})
				})
		})
	}
	
	
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
	
	//create an initial array of APOD cells to populate the collection view
	func createBlankAPODCells() {
		// create a queue
		let downloadQueue = dispatch_queue_create("download", nil)
//		let dates = APODClient.sharedInstance.getAllAPODDates()
		dispatch_async(downloadQueue) { () -> Void in
			//TESTING: replace dates.count with datesTesting.count
			for i in 0..<self.dates.count {
				//do this work using the background shared context rather than block the main UI
				
				//TESTING: replace dates array with datesTesting
				let newAPOD = APOD(dateString: self.dates[i], context: self.backgroundSharedContext)
				self.APODarray.append(newAPOD)
				print("DEBUG: APOD array count is: \(self.APODarray.count)")
				print("Blank APOD for date created: \(newAPOD.dateString)")
			}
			
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				CoreDataStackManager.sharedInstance.saveBackgroundContext()
				
				//****THIS IS CRUCIAL.
				//***APP had to be removed from appstore because this one line was not included in the final build. We were
				//seeing really strange behavious when going from VC1 to VC2 without this line. 
				self.APODarray = self.fetchAllAPODS()
				self.collectionView.reloadData()
			})
		}
	}
	
	func insertBlankAPODCells(noBlankCells: Int) {
		for i in 0..<noBlankCells {
			
			/*
			 * Version 1.1 - The dates were not being updated as it was not really a computed property
			 * Version 1.0 used the global variable dates, as opposed to the local one introduced in version 1.1 below. 
			 * This meant that new dates were never actually created.
			*/
//			let dates = APODClient.sharedInstance.getAllAPODDates()
			let newAPOD = APOD(dateString: self.dates[i], context: self.sharedContext)
			print("DEBUG: creating APOD with dateString \(self.dates[i])")
			APODarray.insert(newAPOD, atIndex: 0)
			CoreDataStackManager.sharedInstance.saveContext()
			print("DEBUG: saving the newly inserted blank apod cell(s)")
		}
	}
	
	func showAlertViewController(title: String? , message: String?) {
		performUIUpdatesOnMain {
			let errorAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
			errorAlert.addAction(UIAlertAction(title: APODConstants.AlertActionTitle, style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(errorAlert, animated: true, completion: nil)
		}
	}
	
}
