//
//  MoreOptionsViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 04/04/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol MyFavoritesMoreOptionsViewControllerDelegate: class {
	func myFavoritesMoreOptionsViewControllerSelectFavorite(controller: MyFavoritesMoreOptionsViewController, removeFromFavorites: Bool)
	func myFavoritesMoreOptionsViewControllerSelectShare(controller: MyFavoritesMoreOptionsViewController)
	func myFavoritesMoreOptionsViewControllerSelectCancel(controller: MyFavoritesMoreOptionsViewController)
}

class MyFavoritesMoreOptionsViewController: UIViewController {
	
	
	weak var delegate: MyFavoritesMoreOptionsViewControllerDelegate?
	@IBOutlet weak var favoriteButton: UIButton!
	var favoriteStatus: Bool = false
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handler), name: "favoriteStatus", object: nil)
		
	}
	
	func handler(notification: NSNotification) {
		print("MyNotification was handled");
		print("userInfo: \(notification.userInfo)");
		print("SelectedCellIndex \(notification.userInfo!["isAlreadyFavorite"])"); //Validate userInfo here. it could be nil
		
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
		delegate?.myFavoritesMoreOptionsViewControllerSelectFavorite(self, removeFromFavorites: favoriteStatus)
	}
	
	
	@IBAction func didSelectShare(sender: UIButton) {
		delegate?.myFavoritesMoreOptionsViewControllerSelectShare(self)
	}
	
	@IBAction func didSelectClose(sender: UIButton) {
		delegate?.myFavoritesMoreOptionsViewControllerSelectCancel(self)
	}
	
	
}

