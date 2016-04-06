//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import CoreData

protocol MyFavoritesAPODViewControllerDelegate: class {
	func myFavoritesAPODViewControllerDidTapMenuButton(controller: MyFavoritesAPODViewController)
}

class MyFavoritesAPODViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, MyFavoritesMoreOptionsViewControllerDelegate, MyFavoritesAPODCollectionViewCellDelegate {

	//MARK: properties

	@IBOutlet weak var collectionView: UICollectionView!

	var APODarray = [APOD]()
	static var dates: [String] = APODClient.sharedInstance.getAllAPODDates()
	weak var delegate: MyFavoritesAPODViewControllerDelegate?
	var apodIndex: NSIndexPath?
	var currentIndexPath: NSIndexPath?
	
	@IBOutlet weak var barButton: UIBarButtonItem!
	@IBOutlet weak var moreOptionsView: UIView!
	@IBOutlet weak var moreOptionsContainerView: UIView!
	@IBOutlet weak var moreOptionsBarButtonItem: UIBarButtonItem!


	//MARK: core data

	lazy var sharedContext: NSManagedObjectContext = {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}()


	//MARK: lifecycle methods

	override func viewDidLoad() {
		super.viewDidLoad()

		moreOptionsView.alpha = 0.0
		moreOptionsContainerView.hidden = true
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		APODarray = fetchFavoriteAPODs()

	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)

		if let index = apodIndex {
			collectionView.scrollToItemAtIndexPath(index, atScrollPosition: .None, animated: false)

		}

	}

	//MARK: core data
	func fetchFavoriteAPODs() -> [APOD] {
		let fetchRequest = NSFetchRequest(entityName: "APOD")
		fetchRequest.predicate = NSPredicate(format: "favorite == %@", true)

		do {
		 return try sharedContext.executeFetchRequest(fetchRequest) as! [APOD]
		} catch {
			return [APOD]()
		}
	}

	//MARK: menu button delegate methods

	@IBAction func menuButtonTapped(sender: AnyObject) {
		if let _ = apodIndex {
			navigationController?.popToRootViewControllerAnimated(true)
		} else {
			delegate?.myFavoritesAPODViewControllerDidTapMenuButton(self)
		}
	}


	//MARK: collection view

	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APODarray.count
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyFavoritesAPODCollectionViewCell", forIndexPath: indexPath) as! MyFavoritesAPODCollectionViewCell
		currentIndexPath = indexPath
		configureCell(cell, atIndexPath: indexPath)
		return cell
	}


	func configureCell(cell: MyFavoritesAPODCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
		cell.setup()
		cell.delegate = self

		let APOD = APODarray[indexPath.item]
		cell.setupActivityIndicator(cell)

		//if the image has already been downloaded and is in the Documents directory
		if let image = APOD.image {
			
			if !APOD.url!.containsString("http://apod.nasa.gov/")  {
				cell.isAVideoText.hidden = false
				cell.goToWebSite.hidden = false
			}
			
			//show the toolbar
			cell.titleBottomToolbar.hidden = false

			//remove loading image text
			cell.loadingImageText.hidden = true

			cell.activityIndicator.stopAnimating()
			cell.imageView.image = image
			cell.imageTitle.text = APOD.title
			cell.explanation = APOD.explanation
			title = formatDateString(APOD.dateString!)
			
			//additional logic for displaying favorites option
			NSNotificationCenter.defaultCenter().postNotificationName("favoriteStatus", object: nil, userInfo: ["isAlreadyFavorite" : APOD.favorite])

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


	func performUIUpdatesOnMain(updates: () -> Void) {
		dispatch_async(dispatch_get_main_queue()) {
			updates()
		}
	}


	@IBAction func moreOptionsButtonClicked(sender: UIBarButtonItem) {
		showMoreOptionsDetailView()
	}
	
	func myFavoritesMoreOptionsViewControllerSelectFavorite(controller: MyFavoritesMoreOptionsViewController, removeFromFavorites: Bool) {
		let apod = APODarray[currentIndexPath!.item]
		
		if removeFromFavorites == true {
			apod.favorite = false
		} else {
			apod.favorite = true
		}
		
		performUIUpdatesOnMain {
			CoreDataStackManager.sharedInstance.saveContext()
			self.collectionView.reloadData()
		}
	}
	
	
	func myFavoritesMoreOptionsViewControllerSelectShare(controller: MyFavoritesMoreOptionsViewController) {
		let apod = APODarray[currentIndexPath!.row]
		let link = apod.url
		let activityVC = UIActivityViewController(activityItems: [link!, apod.image!], applicationActivities: .None)
		presentViewController(activityVC, animated: true, completion: nil)
	}
	
	func myFavoritesMoreOptionsViewControllerSelectCancel(controller: MyFavoritesMoreOptionsViewController) {
		hideMoreOptionsView()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "MyFavoritesMoreOptionsViewController" {
			let vc = segue.destinationViewController as! MyFavoritesMoreOptionsViewController
			vc.delegate = self
		}
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
	
	
	func myFavoritesAPODCollectionViewCellGoToWebsite(controller: MyFavoritesAPODCollectionViewCell) {
		print("called")
		let apod = APODarray[currentIndexPath!.row]
		let URL = "http://apod.nasa.gov/apod/ap" + convertDateForWebsite(apod.dateString!) + ".html"
		let app = UIApplication.sharedApplication()
		if let url = NSURL(string: URL) {
			if app.canOpenURL(url) {
				app.openURL(url)
			}
		}
	}
	
	func convertDateForWebsite(date: String) -> String {
		let newDate: NSString = date.stringByReplacingOccurrencesOfString("-", withString: "")
		return newDate.substringWithRange(NSRange(location: 2, length: newDate.length-2)) as String
	}
}
