//
//  MoreOptionsTableViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 03/04/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol MoreOptionsTableViewControllerDelegate: class {
	func moreOptionsTableViewController(controller: MoreOptionsTableViewController, didSelectRow row: Int)
}

class MoreOptionsTableViewController: UITableViewController {

	weak var delegate: MoreOptionsTableViewControllerDelegate?
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		delegate?.moreOptionsTableViewController(self, didSelectRow: indexPath.row)
	}

}
