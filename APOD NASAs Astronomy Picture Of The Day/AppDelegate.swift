 //
//  AppDelegate.swift
//  Astronomy Picture Of The Day - NASAs APOD
//
//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	struct Constants {
		
		//amount of mainViewController that overlaps with Menu
		static let MenuOverlap: CGFloat = 80
	}
	
	//MARK: properties
	
	var childViewControllers = [UIViewController]()
	var childNav: UINavigationController!
	var menuNav: UINavigationController!
	var sideBarVC: SidebarViewController!
	
	
	func applicationDidEnterBackground(application: UIApplication) {
		print("DEBUG: application went into the background")
	}
	
	func applicationWillEnterForeground(application: UIApplication) {
		print("DEBUG: application has entered the foreground")
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		print("DEBUG: application has become active")
	}
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		print("DEBUG: didFinishLaunchingWithOptions has been called")
		
		let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		
		//app wide color scheme
		UINavigationBar.appearance().barTintColor = UIColor.blackColor()
		UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
		
		//instantiate child view controllers
		let vc1 = storyboard.instantiateViewControllerWithIdentifier("ViewControllerOne") as! ViewControllerOne
		vc1.delegate = self
		
		let vc2 = storyboard.instantiateViewControllerWithIdentifier("ViewControllerTwo") as! ViewControllerTwo
		vc2.delegate = self
		
		let vc3 = storyboard.instantiateViewControllerWithIdentifier("MyFavoritesViewController") as! MyFavoritesViewController
		vc3.delegate = self
		
		let vc4 = storyboard.instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
		vc4.delegate = self
		
		//add the static view controllers to array
		childViewControllers.append(vc1)
		childViewControllers.append(vc2)
		childViewControllers.append(vc3)
		childViewControllers.append(vc4)
		
		//get the child navigational controller
		childNav = UINavigationController(rootViewController: childViewControllers[0])
		
		//instantiate menu view controller
		let menuVC = storyboard.instantiateViewControllerWithIdentifier("MenuTableViewController") as! MenuTableViewController
		menuVC.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
		menuVC.tableView.tableFooterView = UIView()  //removes additional lines underneath menu items
		menuVC.delegate = self
		menuNav = UINavigationController(rootViewController: menuVC)
		
		//create side bar view controller
		sideBarVC = SidebarViewController(leftViewController: menuNav, mainViewController: childNav, overlap: Constants.MenuOverlap)
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.backgroundColor = UIColor.whiteColor()
		window?.rootViewController = sideBarVC
		window?.tintColor = UIColor.blackColor()
		window?.makeKeyAndVisible()
		
		return true
	}
	
}

extension AppDelegate: ViewControllerOneDelegate {
	func viewControllerOneDidTapMenuButton(controller: ViewControllerOne) {
		sideBarVC.toggleLeftMenuAnimated(true)
	}
}

extension AppDelegate: ViewControllerTwoDelegate {
	func viewControllerTwoDidTapMenuButton(controller: ViewControllerTwo) {
		sideBarVC.toggleLeftMenuAnimated(true)
	}
}

extension AppDelegate: MyFavoritesViewControllerDelegate {
	func myFavoritesViewControllerDidTapMenuButton(controller: MyFavoritesViewController) {
		sideBarVC.toggleLeftMenuAnimated(true)
	}
}

extension AppDelegate: AboutViewControllerDelegate {
	func aboutViewControllerDelegateDidTapMenuButton(controller: AboutViewController) {
		sideBarVC.toggleLeftMenuAnimated(true)
	}
}

extension AppDelegate: MenuTableViewControllerDelegate {
	func menuTableViewController(controller: MenuTableViewController, didSelectRow row: Int) {
		
		sideBarVC.closeMenuAnimated(true)
		let destinationViewController = childViewControllers[row]
		if childNav.topViewController != destinationViewController {
			childNav.setViewControllers([destinationViewController], animated: true)
		}
	}
}
