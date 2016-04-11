//
//  MoreOptionsViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 04/04/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol MoreOptionsViewControllerDelegate: class {
	func moreOptionsViewControllerSelectFavorite(controller: MoreOptionsViewController, removeFromFavorites: Bool)
	func moreOptionsViewControllerSelectShare(controller: MoreOptionsViewController)
	func moreOptionsViewControllerSelectCancel(controller: MoreOptionsViewController)
}

class MoreOptionsViewController: UIViewController {
	
	
	weak var delegate: MoreOptionsViewControllerDelegate?
	@IBOutlet weak var favoriteButton: UIButton!
	var favoriteStatus: Bool = false
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handler), name: "favoriteStatus", object: nil)
		
	}
	
	func handler(notification: NSNotification) {
		if let notification = notification.userInfo!["isAlreadyFavorite"] as? Bool {
			if notification == true {
				favoriteStatus = true
				favoriteButton.setTitle("Remove from My Favorites", forState: .Normal)
			} else {
				favoriteStatus = false
				favoriteButton.setTitle("Add to My Favorites", forState: .Normal)
			}
		}
		
	}
	
	@IBAction func didSelectFavorite(sender: UIButton) {
		delegate?.moreOptionsViewControllerSelectFavorite(self, removeFromFavorites: favoriteStatus)
	}
	
	
	@IBAction func didSelectShare(sender: UIButton) {
		delegate?.moreOptionsViewControllerSelectShare(self)
	}
	
	@IBAction func didSelectClose(sender: UIButton) {
		delegate?.moreOptionsViewControllerSelectCancel(self)
	}
	
	
}

