//
//  ViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class PictureOfTheDayViewController: UIViewController {
	
	@IBOutlet weak var imageAPOD: UIImageView!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		APODClient.sharedInstance.downloadPhotoProperties({ (data, error) in
			let url = NSURL(string: data!)
			let imageData = NSData(contentsOfURL: url!)
			dispatch_async(dispatch_get_main_queue()) {
				self.imageAPOD.image = UIImage(data: imageData!)
			}
		})
		
	}
	
	
	func dateToString(date: NSDate) -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-DD"
		return dateFormatter.stringFromDate(date)
	}
	
}
