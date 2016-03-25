//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	var APODarray: [APOD] = []
	private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
	
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
		
		for i in 0..<8 {
			
			APODClient.sharedInstance.downloadPhotoProperties(dates[i], completionHandler: { (data, error) in
				
				guard error == nil else {
					print("error")
					return
				}
				
				guard let data: [String: String] = data else {
					print("error")
					return
				}
				
				print(data)
				
				//create an APOD image object
				let newAPOD = APOD(dateString: data["date"]!)
				newAPOD.explanation = data["explanation"]
				newAPOD.title = data["title"]
				newAPOD.url = data["url"]
				
				//create an image based on url string
				let url = NSURL(string: newAPOD.url!)
				let imageData = NSData(contentsOfURL: url!)
				dispatch_async(dispatch_get_main_queue()) {
					newAPOD.image = UIImage(data: imageData!)
					self.APODarray.append(newAPOD)
					self.collectionView.reloadData()
				}
			})
		}
	}
	
	@IBAction func menuButtonTapped(sender: AnyObject) {
		delegate?.viewControllerOneDidTapMenuButton(self)
	}
	
	
	//MARK: collection View
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APODarray.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("APODCollectionViewCell", forIndexPath: indexPath) as! APODCollectionViewCell
		cell.backgroundColor = UIColor.yellowColor()
		
		let APOD = APODarray[indexPath.row]
		cell.imageView.image = APOD.image
		//		cell.imageTitle.text = APOD.title
		return cell
	}
	
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		return CGSize(width: collectionView.frame.size.width - 10, height: collectionView.frame.size.height)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
	{
		return UIEdgeInsetsMake(0, 5, 0, 5)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 10
	}
	
}
