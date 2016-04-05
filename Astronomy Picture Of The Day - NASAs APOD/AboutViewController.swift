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

	@IBOutlet weak var labelOne: UILabel!
	@IBOutlet weak var labelTwo: UILabel!
	@IBOutlet weak var labelThree: UILabel!

	@IBOutlet weak var image: UIImageView!
	
	weak var delegate: AboutViewControllerDelegate?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        labelOne.text = "Astronomy Picture of the Day (APOD) is originated, written, coordinated, and edited since 1995 by Robert Nemiroff and Jerry Bonnell. The APOD Archive contains the largest collection of annotated astronomical images on the Internet."
		
		labelTwo.text = "APOD is a service of: ASD at NASA/GSFC and Michigan Technological University."
		
		labelThree.text = "APOD for iOS is an open source project with all source code freely available on Github. Why not contribute and make the app even better."
    }
	
	@IBAction func menuButtonTapped(sender: UIBarButtonItem) {
		delegate?.aboutViewControllerDelegateDidTapMenuButton(self)
	}
	
}
