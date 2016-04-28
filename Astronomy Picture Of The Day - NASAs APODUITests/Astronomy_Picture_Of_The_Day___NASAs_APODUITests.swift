//
//  Astronomy_Picture_Of_The_Day___NASAs_APODUITests.swift
//  Astronomy Picture Of The Day - NASAs APODUITests
//
//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import XCTest

class Astronomy_Picture_Of_The_Day___NASAs_APODUITests: XCTestCase {
	
	let app = XCUIApplication()
	
	override func setUp() {
        super.setUp()
		
		setupSnapshot(app)
		app.launch()
		
		XCUIDevice.sharedDevice().orientation = .Portrait
    }
	
	func testTakeScreenshots() {
		snapshot("Todays APOD")

		
		let elementsQuery = app.scrollViews.otherElements
		let toolbarsQuery = elementsQuery.collectionViews.toolbars
		toolbarsQuery.buttons["upArrow"].tap()
		snapshot("Detailed Text")
		
		toolbarsQuery.buttons["downArrow"].tap()

		elementsQuery.navigationBars["27 April 2016"].buttons["menu"].tap()
		snapshot("Menu Bar")
		
		elementsQuery.tables.staticTexts["Gallery"].tap()
		snapshot("Gallery Images")
		
	}
}
