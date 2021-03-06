//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import CoreData

protocol MyFavoritesViewControllerDelegate: class {
	func myFavoritesViewControllerDidTapMenuButton(controller: MyFavoritesViewController)
}

class MyFavoritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
	
	//MARK: properties
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var noFavoritesView: UIView!
	@IBOutlet weak var noFavoritesLabel: UILabel!
	
	var APODarray = [APOD]()
	weak var delegate: MyFavoritesViewControllerDelegate?
	
	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		noFavoritesView.hidden = true
		noFavoritesLabel.hidden = true 
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		APODarray = fetchFavoriteAPODs()
		
		if APODarray.count == 0 {
			title = "No Favorites"
			noFavoritesView.hidden = false
			noFavoritesLabel.hidden = false
		} else {
			title = "My Favorites"
			noFavoritesView.hidden = true
			noFavoritesLabel.hidden = true
		}
		
		collectionView.reloadData()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
	}
	
	//MARK: core data

	lazy var sharedContext: NSManagedObjectContext = {
		return CoreDataStackManager.sharedInstance.managedObjectContext
	}()

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
		delegate?.myFavoritesViewControllerDidTapMenuButton(self)
	}
	
	
	//MARK: collection view
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APODarray.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyFavoritesCollectionViewCell", forIndexPath: indexPath) as! MyFavoritesCollectionViewCell
		configureCell(cell, atIndexPath: indexPath)
		return cell
	}
	
	func configureCell(cell: MyFavoritesCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
		
		let APOD = APODarray[indexPath.item]
		
		if let image = APOD.image {
			cell.imageDate.text = formatDateString(APOD.dateString!)
			cell.imageTitle.text = APOD.title
			cell.imageView.image = image
			if APOD.favorite == true {
				cell.favoriteImage.hidden = false
			} else {
				cell.favoriteImage.hidden = true
			}
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
		let vcOne = storyboard!.instantiateViewControllerWithIdentifier("MyFavoritesAPODViewController") as! MyFavoritesAPODViewController
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
}
