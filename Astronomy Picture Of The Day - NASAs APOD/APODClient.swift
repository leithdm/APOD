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
		static let APIKey = ""
		static let HDImage = "false"
	}
	
	
	//MARK: download photo properties
	
	func downloadPhotoProperties(completionHandler: (data: String?, error: String?) -> Void) {
		
		let methodParameters: [String: AnyObject] = [
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
	
	private func parseDownloadPhotoProperties(data: NSData, completionHandler: (data: String?, error: String?) -> Void) {
		
		var parsedData: AnyObject!
		
		do {
			parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
		} catch {
			completionHandler(data: nil, error: "Error could not parse the data as JSON: '\(data)'")
			return
		}
		
		guard let url = parsedData["url"] as? String else {
			completionHandler(data: nil, error: "Error parsing the data")
			return
		}
		completionHandler(data: url, error: nil)
	}
	
	//MARK: create URL from parameters
	
	private func createURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
		let components = NSURLComponents()
		components.scheme = APOD.APIScheme
		components.host = APOD.APIHost
		components.path = APOD.APIPath
		components.queryItems = [NSURLQueryItem]()
		
		for (key, value) in parameters {
			let queryItem = NSURLQueryItem(name: key, value: "\(value)")
			components.queryItems!.append(queryItem)
		}
		print("Specified URL: \(components.URL!)")
		return components.URL!
	}
}