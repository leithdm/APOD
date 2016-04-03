//
//  MoreOptionsTableViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 03/04/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol MyFavoritesMoreOptionsViewControllerDelegate: class {
	func myFavoritesMoreOptionsViewController(controller: MyFavoritesMoreOptionsViewController, didSelectRow row: Int)
}

class MyFavoritesMoreOptionsViewController: UITableViewController {

	weak var delegate: MyFavoritesMoreOptionsViewControllerDelegate?

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		delegate?.myFavoritesMoreOptionsViewController(self, didSelectRow: indexPath.row)
	}

}
