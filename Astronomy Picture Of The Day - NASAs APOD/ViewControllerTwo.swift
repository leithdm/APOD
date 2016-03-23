//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol ViewControllerTwoDelegate: class {
	func viewControllerTwoDidTapMenuButton(controller: ViewControllerTwo)
}

class ViewControllerTwo: UIViewController {
	weak var delegate: ViewControllerTwoDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	
	@IBAction func menuButtonTapped(sender: AnyObject) {
		delegate?.viewControllerTwoDidTapMenuButton(self)
	}
}
