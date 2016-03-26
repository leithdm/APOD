//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	//MARK: properties
	
	var APODarray: [APOD] = []
	weak var delegate: ViewControllerOneDelegate?
	@IBOutlet weak var collectionView: UICollectionView!
	
	
	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		downloadPhotoProperties()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		collectionView.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height)
	}
	

	//MARK: download photo properties
	
	func downloadPhotoProperties() {
		
		let dates = APODClient.sharedInstance.getAllAPODDates()
		
		//sample data to begin with
		for i in 0..<20 {
			
			APODClient.sharedInstance.downloadPhotoProperties(dates[i], completionHandler: { (data, error) in

				guard error == nil else {
					print("error")
					return
				}
				
				guard let data: [String: String] = data else {
					print("error")
					return
				}
				
				//create an APOD
				let newAPOD = APOD(dateString: data["date"]!)
				newAPOD.explanation = data["explanation"]
				newAPOD.title = data["title"]
				newAPOD.url = data["url"]
				
				//create an image based on url string
				if newAPOD.url!.containsString("youtube") {
					newAPOD.image = UIImage(named: "noPhoto.png")
					dispatch_async(dispatch_get_main_queue()) {
						self.APODarray.append(newAPOD)
						self.collectionView.reloadData()
					}
				} else {
				let url = NSURL(string: newAPOD.url!)
				let imageData = NSData(contentsOfURL: url!)

				dispatch_async(dispatch_get_main_queue()) {
					newAPOD.image = UIImage(data: imageData!)
					self.APODarray.append(newAPOD)
					self.collectionView.reloadData()
				}
				}
			})
		}
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

		//setup scrollview
		
		cell.setup()
		
		let APOD = APODarray[indexPath.row]
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
