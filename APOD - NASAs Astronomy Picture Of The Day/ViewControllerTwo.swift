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
		static let EntityName				= "APOD"
		static let APIURL					= "http://apod.nasa.gov/"
		static let ReusableCellIdentifier	= "GalleryAPODCollectionViewCell"
		static let AlertTitleConnection		= "Connection offline"
		static let AlertMessageConnection	= "Please check your internet connection"
		static let AlertActionTitle			= "Ok"
	}
	
	//MARK: properties
	
	weak var delegate: ViewControllerTwoDelegate?
	var dates: [String] = APODClient.sharedInstance.getAllAPODDates()
	var APODarray = [APOD]()
	var isConnectedToNetwork: Bool =  true
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var datePickerView: UIView!
	
	
	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		APODarray = fetchAllAPODS()
		title = formatDateStringForTitle(dates[0])
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		APODarray = fetchAllAPODS()
		collectionView.reloadData()
		datePickerView.hidden = true
		datePicker.maximumDate = NSDate()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		getImages()
		collectionView.reloadData()
	}
	
	//MARK: core data
	
	lazy var sharedContext: NSManagedObjectContext = {
		return CoreDataStackManager.sharedInstance.managedObjectContext
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
		getImages()
	}
	
	
	//MARK: download photo properties
	
	func getImages() {
		for cell in collectionView.visibleCells() {
			let index: NSIndexPath = collectionView.indexPathForCell(cell)!
			let apod = APODarray[index.item]
			if apod.image == nil {
				getPhotoProperties([dates[index.item]])
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
					
					if !APOD.url!.containsString(APODConstants.APIURL) {
						//typically a video cannot be displayed as an image
						self.performUIUpdatesOnMain({
							APOD.image = UIImage(named: "noPhoto")
							self.collectionView.reloadData()
							CoreDataStackManager.sharedInstance.saveContext()
						})
					} else {
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
			
			if !isConnectedToNetwork {
				cell.activityIndicator.stopAnimating()
				cell.imageView.image = nil
				cell.imageTitle.text = ""
				cell.imageDate.text = ""
				return
			}
			
			cell.imageInfoView.hidden = true
			cell.activityIndicator.startAnimating()
			cell.imageView.image = nil
			cell.imageTitle.text = ""
			cell.imageDate.text = ""
			cell.favoriteImage.hidden = true
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
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
	
	//MARK: date picker
	
	@IBAction func datePickerClicked(sender: UIBarButtonItem) {

		if datePickerView.hidden == true {
			showDatePickerView()
		} else {
			hideDatePickerView()
		}

	}
	
	@IBAction func cancelDatePicker(sender: UIButton) {
		hideDatePickerView()
	}
	
	@IBAction func datePickerGo(sender: UIButton) {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let datePickerDate = dateFormatter.stringFromDate(datePicker.date)
		
		scrollToDate(datePickerDate) { (indexPath) in
			self.performUIUpdatesOnMain({
				self.datePickerView.hidden = true
				
				//leave a delay of 1 second in order for scroll to new indexPath, load the cells, and then get visible cells
				let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
				dispatch_after(delayTime, dispatch_get_main_queue()) {
					self.getImages()
				}
			})
			
		}
	}
	
	//MARK: scroll to date
	
	func scrollToDate(date: String, completionHandler handler: (indexPath: NSIndexPath) -> Void){
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
				for (index, _) in self.APODarray.enumerate() {
					let apod = self.APODarray[index]
					if apod.dateString == date {
						let newIndex = NSIndexPath(forRow: index, inSection: 0)
						self.collectionView.scrollToItemAtIndexPath(newIndex, atScrollPosition: .None, animated: true)
						handler(indexPath: newIndex)
				}
			}
		}
	}
	
	//MARK: animate date picker
	
	func hideDatePickerView() {
		UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: { () -> Void in
			self.datePickerView.center.y += self.datePickerView.bounds.height
			}, completion: { _ in
				self.datePickerView.hidden = true
				self.datePickerView.center.y -= self.datePickerView.bounds.height
		})
	}
	
	func showDatePickerView() {
		//Animate the detail view to appear on screen
		datePickerView.hidden = false
		datePickerView.center.y += view.bounds.height
		UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in
			self.datePickerView.center.y -= self.view.bounds.height
			}, completion: nil)
		datePickerView.hidden = false
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

	
	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}
	
	func showAlertViewController(title: String? , message: String?) {
		performUIUpdatesOnMain {
			let errorAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
			errorAlert.addAction(UIAlertAction(title: APODConstants.AlertActionTitle, style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(errorAlert, animated: true, completion: nil)
		}
	}
	
	//delay function
	func delay(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
}