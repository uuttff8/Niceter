//
//  NiceterUITests.swift
//  NiceterUITests
//
//  Created by uuttff8 on 3/2/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import XCTest

class NiceterUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreatingRoom() {
        
        let app = XCUIApplication()
        app.launch()
        app.navigationBars["Rooms"].buttons["Add"].tap()
        
        let tablesQuery2 = app.tables
        let textView = tablesQuery2.children(matching: .cell).element(boundBy: 0).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.tap()
        textView.typeText("RoomName")
        
        let textView2 = tablesQuery2.children(matching: .cell).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .textView).element
        textView2.tap()
        textView2.tap()
        textView2.typeText("Topic")
        
        let tablesQuery = tablesQuery2
        tablesQuery/*@START_MENU_TOKEN@*/.cells.staticTexts["Members can join this room"]/*[[".cells.staticTexts[\"Members can join this room\"]",".staticTexts[\"Members can join this room\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.staticTexts["GittkerTest"]/*[[".cells.staticTexts[\"GittkerTest\"]",".staticTexts[\"GittkerTest\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Create Room"].buttons["Create"].tap()
        
        
        tablesQuery.staticTexts["GittkerTest/Aasdad"].swipeUp()
        tablesQuery.staticTexts["GittkerTest/RoomName"].tap()
    }
    
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
