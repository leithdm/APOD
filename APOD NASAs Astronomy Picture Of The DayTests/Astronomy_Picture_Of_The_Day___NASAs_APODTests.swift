//
//  Astronomy_Picture_Of_The_Day___NASAs_APODTests.swift
//  Astronomy Picture Of The Day - NASAs APODTests
//
//  Created by Darren Leith on 21/03/2016.
//  Copyright © 2016 Darren Leith. All rights reserved.
//

import XCTest
@testable import Astronomy_Picture_Of_The_Day___NASAs_APOD

class Astronomy_Picture_Of_The_Day___NASAs_APODTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	/*
    func testCreateURLFromParameters() {
		
		let client = APODClient.sharedInstance
		
		let methodParameters: [String: AnyObject] = [
			APODClient.APODParameterKeys.APIKey: "testkey",
			APODClient.APODParameterKeys.HDImage: APODClient.APODParameterValues.HDImage
		]
		
		let url = client.createURLFromParameters(methodParameters)
		let expectedResult = NSURL(string: "https://api.nasa.gov/planetary/apod?hd=false&api_key=testkey")
		
		//Test 1
		XCTAssertNotNil(url)
		
		//Test 2
		XCTAssertEqual(url, expectedResult)
		
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
*/
    
}
