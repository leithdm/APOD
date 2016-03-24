//
//  APODAPI.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation
import UIKit

class APODClient {
	
	static let sharedInstance = APODClient()
	let session = NSURLSession.sharedSession()
	
	
	//MARK: APOD Constants
	
	struct APOD {
		static let APIScheme = "https"
		static let APIHost = "api.nasa.gov"
		static let APIPath = "/planetary/apod"
	}
	
	struct APODParameterKeys {
		static let APIKey = "api_key"
		static let Date = "date"
		static let HDImage = "hd"
	}
	
	struct APODParameterValues {
		static let APIKey = "IyeTTjPu0uEWXZhhXCLriSpOgoIViYvI8LXeVqF5"
		static let HDImage = "false"
	}
	
	
	//MARK: download photo properties
	
	func downloadPhotoProperties(date: String, completionHandler: (data: [String: String]?, error: String?) -> Void) {
		
		let methodParameters: [String: AnyObject] = [
			APODParameterKeys.Date: date,
			APODParameterKeys.APIKey: APODParameterValues.APIKey,
			APODParameterKeys.HDImage: APODParameterValues.HDImage
		]
		
		let request = NSURLRequest(URL: createURLFromParameters(methodParameters))
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			
			guard let data = data else {
				completionHandler(data: nil, error: "Error downloading data from server")
				return
			}
			
			self.parseDownloadPhotoProperties(data, completionHandler: completionHandler)
		}
		task.resume()
	}
	
	
	//MARK: parse photo properties
	
	func parseDownloadPhotoProperties(data: NSData, completionHandler: (data: [String: String]?, error: String?) -> Void) {
		
		var parsedData: AnyObject!
		
		do {
			parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
		} catch {
			completionHandler(data: nil, error: "Error could not parse the data as JSON: '\(data)'")
			return
		}
		
		guard let date = parsedData["date"] as? String else {
			completionHandler(data: nil, error: "Error parsing the date")
			return
		}
		
		guard let url = parsedData["url"] as? String else {
			completionHandler(data: nil, error: "Error parsing the url")
			return
		}
		
		guard let title = parsedData["title"] as? String else {
			completionHandler(data: nil, error: "Error parsing the title")
			return
		}
		
		guard let explanation = parsedData["explanation"] as? String else {
			completionHandler(data: nil, error: "Error parsing the explanation text")
			return
		}
		
		var returnedData: [String: String] = [:]
		returnedData["date"] = date
		returnedData["url"] = url
		returnedData["title"] = title
		returnedData["explanation"] = explanation
		
		completionHandler(data: returnedData, error: nil)
	}
	
	//MARK: create URL from parameters
	
	func createURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
		let components = NSURLComponents()
		components.scheme = APOD.APIScheme
		components.host = APOD.APIHost
		components.path = APOD.APIPath
		components.queryItems = [NSURLQueryItem]()
		
		for (key, value) in parameters {
			let queryItem = NSURLQueryItem(name: key, value: "\(value)")
			components.queryItems!.append(queryItem)
		}
		//		print("Specified URL: \(components.URL!)")
		return components.URL!
	}
	
	//MARK: helper methods
	
	func dateToString(date: NSDate) -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-DD"
		return dateFormatter.stringFromDate(date)
	}
	
	
	//an array of strings for every date from 15th July 1995 to present
	
	func getAllAPODDates() -> [String] {
		var returnArray = [String]()
		
		//TODO: remove magic number and date format
		let originDateString = "1995-07-15"
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		let dateValue1 = dateFormatter.dateFromString(originDateString) as NSDate!
		let dateValue2 = NSDate()
		
		let calendar = NSCalendar.currentCalendar()
		let flags: NSCalendarUnit = NSCalendarUnit.Day
		
		let components = calendar.components(flags, fromDate: dateValue1, toDate: dateValue2, options: NSCalendarOptions.MatchStrictly)
		
		for index in 0...components.day {
			let components = NSDateComponents()
			components.day = index
			let newDate = calendar.dateByAddingComponents(components, toDate: dateValue1, options: NSCalendarOptions.MatchStrictly)!
			returnArray.insert(dateFormatter.stringFromDate(newDate), atIndex: 0)
		}
		return returnArray
	}
}