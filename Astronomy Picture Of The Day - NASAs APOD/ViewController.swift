//
//  ViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var imageAPOD: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		parseAPI { (data) -> Void in
			let url = NSURL(string: data)
			let imageData = NSData(contentsOfURL: url!)
			dispatch_async(dispatch_get_main_queue()) {
				self.imageAPOD.image = UIImage(data: imageData!)
			}
		}
	}

	
	func dateToString(date: NSDate) -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-DD"
		return dateFormatter.stringFromDate(date)
	}
	
	
	func parseAPI(completionHandler: (data: String) -> Void) {
		
		let stringURL = APODAPI.Constants.BASE_URL + APODAPI.Constants.API_KEY
		let session = NSURLSession.sharedSession()
		let request = NSURLRequest(URL: NSURL(string: stringURL)!)
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			//guard statements for error, response
			
			guard let data = data else {
				//error
				return
			}
			
			//parse the data
			var parsedData: AnyObject!
			
			do {
				parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
			} catch {
				parsedData = nil
				return
			}
			
			guard let url = parsedData["url"] as? String else { //for example
				print("error")
				return
			}
			print(url)
			completionHandler(data: url)
		}
		task.resume()
	}
}
