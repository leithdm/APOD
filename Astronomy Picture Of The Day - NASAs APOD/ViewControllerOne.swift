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
		
		//TODO: update for landscape
		let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
		layout.itemSize = CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height/2)
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
	
	
	//MARK: - Collection View
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APODarray.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("APODCollectionViewCell", forIndexPath: indexPath) as! APODCollectionViewCell
		 cell.backgroundColor = UIColor.blackColor()
		
		let APOD = APODarray[indexPath.row]
		cell.imageView.image = APOD.image
//		cell.imageTitle.text = APOD.title
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: 100, height: 100)

	}
	
	
}
