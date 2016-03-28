//
//  APODImage.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 24/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import Foundation
import UIKit

class APOD {
	
	var dateString: String?
	var explanation: String?
	var title: String?
	var url: String?
	var image: UIImage?
	var activityIndicator: UIActivityIndicatorView?
	var loadingLabel: UILabel?
		
	init(dateString: String) {
		self.dateString = dateString
	}
	
}
