//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: class {
  func menuTableViewController(controller: MenuTableViewController, didSelectRow row: Int)
}

class MenuTableViewController: UITableViewController {
  weak var delegate: MenuTableViewControllerDelegate?

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
	tableView.deselectRowAtIndexPath(indexPath, animated: true)
    delegate?.menuTableViewController(self, didSelectRow: indexPath.row)
  }
}
