//
//  TrakxTests.swift
//  TrakxTests
//
//  Created by Matt Croxson on 8/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import XCTest

class TrakxTests: XCTestCase {
   
   func testSettingsModel() {
      // Model to test
      let model = SettingsModel()
      
      // Test scheduled notification count from UIApplication matched the value returned from the model.
      XCTAssert(UIApplication.sharedApplication().scheduledLocalNotifications?.count == model.reminderCount)
   }
   
   func testPTVCommonData() {
      
      let version = PTVCommonData.apiVersion
      let baseURL = PTVCommonData.baseURL
      
      let combined = "\(baseURL)\(version)/"
      
      XCTAssert(combined == PTVCommonData.baseURLWithVersion)
      
   }
   
   func testLocationReminder() {
      
      // Model to test
      let model = ReminderModel.sharedModel
      
      // Test stop for model testing.
      let testStop = PTVStop(suburb: "Sunbury", transportType: PTVLineType.MetroTrain, stopID: 1234, locationName: "Sunbury Station", latitude: 23.4567, longitude: -143.2392, distance: 0)
      
      // Confirm location reminder is not set
      XCTAssert(model.locationReminderIsSet(forStop: testStop).setting == false)
      
      // Set location reminder
      model.setLocationReminder(forStop: testStop, enabled: true)
      
      // Confirm location reminder has been set
      XCTAssert(model.locationReminderIsSet(forStop: testStop).setting == true)
      
      // Remove the location reminder
      model.setLocationReminder(forStop: testStop, enabled: false)
      
      // Confirm location reminder has been removed
      XCTAssert(model.locationReminderIsSet(forStop: testStop).setting == false)
   }
   
   func testTimetableReminder() {
      
      // Model to test
      let model = ReminderModel.sharedModel
      
      // Test timetable item for model testing.
      let testFlags = PTVTimetableFlags(flagString: "")
      let testStop = PTVStop(suburb: "Sunbury", transportType: PTVLineType.MetroTrain, stopID: 1234, locationName: "Sunbury Station", latitude: 23.4567, longitude: -143.2392, distance: 0)
      let testLine = PTVLine(transportType: .MetroTrain, routeType: .MetroTrain, lineID: 5948, lineName: "Sunbury Line", lineNumber: "Sunbury Line", lineNameShort: "Sunbury Line", lineNumberLong: "Sunbury Line")
      let testDirection = PTVDirection(lineDirectionID: 2345, directionID: 3234, directionName: "Sunbury", line: testLine)
      let testPlatform = PTVPlatform(id: 100, stop: testStop, direction: testDirection)
      let testRun = PTVRun(type: .MetroTrain, runID: 1234, numSkipped: 0, destinationID: 0, destinationName: "Nowhereville")
      let testTimetableItem = PTVTimetableItem(timetableTime: NSDate().dateByAddingTimeInterval(200), realtimeTime: nil, flags: testFlags, platform: testPlatform, run: testRun)
      
      // Confirm location reminder is not set
      XCTAssert(model.timetableReminderIsSet(forTimetableItem: testTimetableItem).setting == false)
      
      // Set location reminder
      model.setTimetableReminder(forTimetableItem: testTimetableItem, enabled: true)
      
      // Confirm location reminder has been set
      XCTAssert(model.timetableReminderIsSet(forTimetableItem: testTimetableItem).setting == true)
      
      // Remove the location reminder
      model.setTimetableReminder(forTimetableItem: testTimetableItem, enabled: false)
      
      // Confirm location reminder has been removed
      XCTAssert(model.timetableReminderIsSet(forTimetableItem: testTimetableItem).setting == false)
   }
}

