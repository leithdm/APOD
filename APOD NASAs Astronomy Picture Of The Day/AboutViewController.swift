//
//  AboutViewController.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 04/04/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit
import MessageUI

protocol AboutViewControllerDelegate: class {
	func aboutViewControllerDelegateDidTapMenuButton(controller: AboutViewController)
}


class AboutViewController: UIViewController {
	
	//MARK: Constants
	
	struct Constants {
		static let LabelOneText = "Astronomy Picture of the Day (APOD) is a website provided by NASA and Michigan Technological University (MTU)."
		static let LabelTwoText = "Each day a different image or photograph of our universe is featured, along with a brief explanation by a professional astronomer."

	}

	@IBOutlet weak var labelOne: UILabel!
	@IBOutlet weak var labelTwo: UILabel!
	@IBOutlet weak var logo: UIImageView!
	@IBOutlet weak var supportButton: UIButton!
	
	weak var delegate: AboutViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let modelName = UIDevice.currentDevice().modelName
		
		if modelName == "iPhone 4" || modelName == "iPhone 4s" {
			labelOne.font = UIFont(name: "GillSans", size: 18)
			labelTwo.font = UIFont(name: "GillSans", size: 18)
		}
		
		if modelName == "iPhone 5" || modelName == "iPhone 5c" || modelName == "iPhone 5s" {
			labelOne.font = UIFont(name: "GillSans", size: 22)
			labelTwo.font = UIFont(name: "GillSans", size: 22)
		}

        labelOne.text = Constants.LabelOneText
		labelTwo.text = Constants.LabelTwoText
		supportButton.layer.cornerRadius = 10
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		labelOne.center.x += view.bounds.width
		labelTwo.center.x += view.bounds.width
		logo.center.x -= view.bounds.width
		supportButton.center.x -= view.bounds.width
		animateViews()
	}
	
	@IBAction func menuButtonTapped(sender: UIBarButtonItem) {
		delegate?.aboutViewControllerDelegateDidTapMenuButton(self)
	}
	
	//send an email for support
	@IBAction func sendSupportEmailButtonTapped(sender: AnyObject) {
		let mailComposeViewController = configuredMailComposeViewController()
		if MFMailComposeViewController.canSendMail() {
			self.presentViewController(mailComposeViewController, animated: true, completion: nil)
		} else {
			self.showSendMailErrorAlert()
		}
	}
	
	
	func animateViews() {
		//label one
		UIView.animateWithDuration(1.0, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: { () -> Void in
			self.labelOne.center.x -= self.view.bounds.width
			}, completion: nil)
		
		//label two
		UIView.animateWithDuration(1.0, delay: 0.6, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: { () -> Void in
			self.labelTwo.center.x -= self.view.bounds.width
			}, completion: nil)
		
		//logo
		UIView.animateWithDuration(1.0, delay: 0.9, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: { () -> Void in
			self.logo.center.x += self.view.bounds.width
			}, completion: nil)
		
		//support button
		UIView.animateWithDuration(1.0, delay: 0.9, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: { () -> Void in
			self.supportButton.center.x += self.view.bounds.width
			}, completion: nil)
	}
}

extension AboutViewController: MFMailComposeViewControllerDelegate {
	
	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
		
		mailComposerVC.setToRecipients(["support@lethalapps.com"])
		mailComposerVC.setSubject("APOD - NASAs Astronomy Picture Of The Day iOS")
		
		return mailComposerVC
	}
	
	func showSendMailErrorAlert() {
		let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .Alert)
		presentViewController(sendMailErrorAlert, animated: true, completion: nil)
	}
	
	// MARK: MFMailComposeViewControllerDelegate
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}


public extension UIDevice {
	
	var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8 where value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		
		switch identifier {
		case "iPod5,1":                                 return "iPod Touch 5"
		case "iPod7,1":                                 return "iPod Touch 6"
		case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
		case "iPhone4,1":                               return "iPhone 4s"
		case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
		case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
		case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
		case "iPhone7,2":                               return "iPhone 6"
		case "iPhone7,1":                               return "iPhone 6 Plus"
		case "iPhone8,1":                               return "iPhone 6s"
		case "iPhone8,2":                               return "iPhone 6s Plus"
		case "iPhone8,4":                               return "iPhone SE"
		case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
		case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
		case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
		case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
		case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
		case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
		case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
		case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
		case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
		case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
		case "AppleTV5,3":                              return "Apple TV"
		case "i386", "x86_64":                          return "Simulator"
		default:                                        return identifier
		}
	}
	
}
