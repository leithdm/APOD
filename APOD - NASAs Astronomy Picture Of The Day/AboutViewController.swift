//
//  AboutViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 04/04/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

protocol AboutViewControllerDelegate: class {
	func aboutViewControllerDelegateDidTapMenuButton(controller: AboutViewController)
}


class AboutViewController: UIViewController {
	
	//MARK: Constants
	
	struct Constants {
		static let LabelOneText		= "Astronomy Picture of the Day (APOD) is a website provided by NASA and Michigan Technological University (MTU)."
		static let LabelTwoText		= "Each day a different image or photograph of our universe is featured, along with a brief explanation by a professional astronomer."

	}

	@IBOutlet weak var labelOne: UILabel!
	@IBOutlet weak var labelTwo: UILabel!
	@IBOutlet weak var logo: UIImageView!
	
	weak var delegate: AboutViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
		
        labelOne.text = Constants.LabelOneText
		labelTwo.text = Constants.LabelTwoText
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		labelOne.center.y -= view.bounds.width
		labelTwo.center.x += view.bounds.width
		labelTwo.alpha = 0.0
		logo.center.x -= view.bounds.width
		animateViews()
	}
	
	@IBAction func menuButtonTapped(sender: UIBarButtonItem) {
		delegate?.aboutViewControllerDelegateDidTapMenuButton(self)
	}
	
	
	func animateViews() {
		//Label one
		UIView.animateWithDuration(1.1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: { () -> Void in
			self.labelOne.center.x -= self.view.bounds.width
			}, completion: nil)
		
		//Label two
		UIView.animateWithDuration(1.3, delay: 0.7, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: { () -> Void in
			self.labelTwo.center.x -= self.view.bounds.width
			self.labelTwo.alpha = 1.0
			}, completion: nil)
		
		//Logo
		UIView.animateWithDuration(1.3, delay: 1.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: { () -> Void in
			self.logo.center.x += self.view.bounds.width
			}, completion: nil)
	}
}
