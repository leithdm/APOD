//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import UIKit

class SidebarViewController: UIViewController {
	
	var leftViewController: UIViewController!
	var mainViewController: UIViewController!
	var overlap: CGFloat!
	var scrollView: UIScrollView!
	var firstTime = true
	
	required init?(coder aDecoder: NSCoder) {
		assert(false, "Use init(leftViewController:mainViewController:overlap:)")
		super.init(coder: aDecoder)
	}
	
	override func viewDidLayoutSubviews() {
		if firstTime {
			firstTime = false
			closeMenuAnimated(false)
		}
	}
	
	init(leftViewController: UIViewController, mainViewController: UIViewController, overlap: CGFloat) {
		self.leftViewController = leftViewController
		self.mainViewController = mainViewController
		self.overlap = overlap
		
		super.init(nibName: nil, bundle: nil)
		
		self.view.backgroundColor = UIColor.blackColor()
		setupScrollView()
		setupViewControllers()
	}
	
	func setupScrollView() {
		scrollView = UIScrollView()
		scrollView.pagingEnabled = true
		scrollView.bounces = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		
		//pin the horizontal and vertical constraints to the edges using VFL
		let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView])
		let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView])
		NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints)
	}
	
	func setupViewControllers() {
		addViewController(leftViewController)
		addViewController(mainViewController)
		
		let views = ["left": leftViewController.view, "main": mainViewController.view, "outer": view]
		let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
			"|[left][main(==outer)]|", options: [.AlignAllTop, .AlignAllBottom], metrics: nil, views: views)
		let leftWidthConstraint = NSLayoutConstraint(
			item: leftViewController.view,
			attribute: .Width,
			relatedBy: .Equal,
			toItem: view,
			attribute: .Width,
			multiplier: 1.0, constant: -overlap)
		let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
			"V:|[main(==outer)]|", options: [], metrics: nil, views: views)
		NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints + [leftWidthConstraint])
		addShadowToView(mainViewController.view)
	}
	
	func leftMenuIsOpen() -> Bool {
		return scrollView.contentOffset.x == 0
	}
	
	func openLeftMenuAnimated(animated: Bool) {
		scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
	}
	
	func toggleLeftMenuAnimated(animated: Bool) {
		if leftMenuIsOpen() {
			closeMenuAnimated(animated)
		} else {
			openLeftMenuAnimated(animated)
		}
	}
	
	private func addViewController(viewController: UIViewController) {
		viewController.view.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(viewController.view)
		addChildViewController(viewController)
		viewController.didMoveToParentViewController(self)
	}
	
	private func addShadowToView(destView: UIView) {
		destView.layer.shadowPath = UIBezierPath(rect: destView.bounds).CGPath
		destView.layer.shadowRadius = 2.5
		destView.layer.shadowOffset = CGSize(width: 0, height: 0)
		destView.layer.shadowOpacity = 1.0
		destView.layer.shadowColor = UIColor.blackColor().CGColor
	}
	
	func closeMenuAnimated(animated: Bool) {
		scrollView.setContentOffset(
			CGPoint(x: CGRectGetWidth(leftViewController.view.frame),
				y: 0),
			animated: animated)
	}
}
