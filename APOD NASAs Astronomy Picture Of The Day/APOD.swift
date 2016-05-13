//
//  APODImage.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 24/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class APOD: NSManagedObject {
	
	@NSManaged var dateId: NSDate?
	@NSManaged var dateString: String?
	@NSManaged var explanation: String?
	@NSManaged var title: String?
	@NSManaged var url: String?
	@NSManaged var favorite: Bool


	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dateString: String, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("APOD", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.dateString = dateString
		favorite = false
		self.dateId = createDateFromString()
	}
	
	func createDateFromString() -> NSDate {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.dateFromString(dateString!)!
	}
	
	//images are retrieved/set via the Documents directory
	var image: UIImage? {
		get {
			return APODClient.Caches.imageCache.imageWithIdentifier("\(dateString)")
		}
		
		set {
			APODClient.Caches.imageCache.storeImage(newValue, withIdentifier: "\(dateString)") //newValue being the default value
		}
	}
	
}
