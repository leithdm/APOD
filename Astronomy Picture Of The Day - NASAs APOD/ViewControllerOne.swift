//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol ViewControllerOneDelegate: class {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne)
}

class ViewControllerOne: UIViewController {
	weak var delegate: ViewControllerOneDelegate?
	
	@IBOutlet weak var imageAPOD: UIImageView!
	
	
	//MARK: lifecycle methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		downloadPhotoProperties()
	}
	
	
	//MARK: download photo properties
	
	func downloadPhotoProperties() {
		
		APODClient.sharedInstance.downloadPhotoProperties({ (data, error) in
			let url = NSURL(string: data!)
			let imageData = NSData(contentsOfURL: url!)
			dispatch_async(dispatch_get_main_queue()) {
				self.imageAPOD.image = UIImage(data: imageData!)
			}
		})
	}
	
	
	@IBAction func menuButtonTapped(sender: AnyObject) {
		delegate?.viewControllerOneDidTapMenuButton(self)
	}
}
