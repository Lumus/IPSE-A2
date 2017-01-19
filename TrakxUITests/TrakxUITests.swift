//
//  TrakxUITests.swift
//  TrakxUITests
//
//  Created by Matt Croxson on 8/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import XCTest

class TrakxUITests: XCTestCase {
   
   override func setUp() {
      super.setUp()
      
      // Put setup code here. This method is called before the invocation of each test method in the class.
      
      // In UI tests it is usually best to stop immediately when a failure occurs.
      continueAfterFailure = false
      // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
      XCUIApplication().launch()
      
      // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
   }
   
   override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
   }
   
   func testTabBarNavigation() {
      
      // Test tapping on various tab bar buttons to confirm tab bar controller operation. Last screen should be the stops nearby tab.
      
      let tabBarsQuery = XCUIApplication().tabBars
      let disruptionsButton = tabBarsQuery.buttons["Disruptions"]
      disruptionsButton.tap()
      XCTAssert(disruptionsButton.selected)
      
      let favouritesButton = tabBarsQuery.buttons["Favourites"]
      favouritesButton.tap()
      XCTAssert(favouritesButton.selected)
      
      let searchButton = tabBarsQuery.buttons["Search"]
      searchButton.tap()
      XCTAssert(searchButton.selected)
      
      tabBarsQuery.buttons["Settings"].tap()
      XCTAssert(tabBarsQuery.buttons["Settings"].selected)
      
      searchButton.tap()
      XCTAssert(searchButton.selected)
      
      favouritesButton.tap()
      XCTAssert(favouritesButton.selected)
      
      disruptionsButton.tap()
      XCTAssert(disruptionsButton.selected)
      
      tabBarsQuery.buttons["Stops Nearby"].tap()
      XCTAssert(tabBarsQuery.buttons["Stops Nearby"].selected)
   }
   

   func testDisruptionModeSelection() {
      
      XCUIApplication().tabBars.buttons["Disruptions"].tap()
      
      
      let app = XCUIApplication()
      app.tabBars.buttons["Disruptions"].tap()
      
      NSThread.sleepForTimeInterval(4)
      
      let tablesQuery = app.tables
      tablesQuery.staticTexts["Metro Train"].tap()
      
      tablesQuery.staticTexts["Lifts currently out of order at Parliament Station"].tap()
      
      XCTAssert(app.navigationBars["Disruption"].exists)
      
      app.navigationBars.matchingIdentifier("Disruption").buttons["Metro Train"].tap()
      app.navigationBars.matchingIdentifier("Metro Train").buttons["Disruptions"].tap()
      
      
   }
   
   func testFavouritesDelete() {
      
      let app = XCUIApplication()
      app.tabBars.buttons["Favourites"].tap()
      
      let tablesQuery = app.tables
      tablesQuery.staticTexts["Melton"].swipeLeft()
      tablesQuery.buttons["Delete"].tap()
      
      XCTAssert(tablesQuery.staticTexts["Melton"].exists == false)
      
   }
   
   func testStopDetailView() {
      
      let app = XCUIApplication()
      let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element
      element.childrenMatchingType(.Map).element.pressForDuration(0.9);
      
      NSThread.sleepForTimeInterval(3)
      
      app.otherElements["Sunbury Station Pin"].tap()
      
      element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).tap()
      
      let tablesQuery = app.tables
      
      tablesQuery.buttons["FavouriteButton"].tap()
      tablesQuery.buttons["ReminderButton"].tap()
      
      app.navigationBars["Sunbury Station"].buttons["Stops Nearby"].tap()
   }
}
