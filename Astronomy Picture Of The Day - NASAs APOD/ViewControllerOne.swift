//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController, UICollectionViewDataSource {
	
	var APODarray: [UIImage] = []
	
	weak var delegate: ViewControllerOneDelegate?
	@IBOutlet weak var imageTitle: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		downloadPhotoProperties()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
		layout.itemSize = CGSize(width: collectionView.bounds.size.width, height: 400) 	}
	
	
	//MARK: download photo properties
	
	func downloadPhotoProperties() {
		
		APODClient.sharedInstance.downloadPhotoProperties({ (data, error) in
			let url = NSURL(string: data!)
			let imageData = NSData(contentsOfURL: url!)
			dispatch_async(dispatch_get_main_queue()) {
				let image = UIImage(data: imageData!)
				self.APODarray.append(image!)
				self.APODarray.append(image!)
				self.APODarray.append(image!)
				self.imageTitle.text = data
				self.collectionView.reloadData()
				print(self.APODarray)
			}
		})
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
		
		let image = APODarray[indexPath.row]
		cell.imageView.image = image
		
		//		cell.imageAPOD.layer.shadowRadius = 4
		//		cell.imageAPOD.layer.shadowOpacity = 0.5
		//		cell.imageAPOD.layer.shadowOffset = CGSize.zero
		
		return cell
	}
}
