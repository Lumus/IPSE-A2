//
//  StoppingPatternModel.swift
//  Trakx
//
//  Created by Matt Croxson on 20/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol StoppingPatternModelDelegate {
   func stoppingPatternDidUpdate()
   func stoppingPatternUpdateFailed()
}

class StoppingPatternModel {
   
   // Properties.
   private var run: PTVRun
   private var stop: PTVStop
   private var line: PTVLine
   private var delegate: StoppingPatternModelDelegate?
   
   // Reminder model instance.
   private let reminderModel = ReminderModel.sharedModel
   
   // Stopping pattern array.
   private var stoppingPattern: [PTVTimetableItem] = []
   
   // Initialiser
   init(stop: PTVStop, run: PTVRun, line: PTVLine, delegate: StoppingPatternModelDelegate? = nil) {
      
      self.stop = stop
      self.run = run
      self.line = line
      self.delegate = delegate

   }
   
   // Returns the total number of sections
   var numberOfSections: Int {
      get {
         return 1
      }
   }
   
   // Returns the total number of stops in the specific section index.
   func numberOfStopsInSection(section: Int) -> Int {
      return self.stoppingPattern.count
   }
   
   // Returns a timetable item for a specific index path.
   func itemAtIndexPath(indexPath: NSIndexPath) -> PTVTimetableItem {
      return self.stoppingPattern[indexPath.row]
   }
   
   // Toggles the reminder status for an specifc index path. Returns a tuple containing the new setting, the success, and error message if applicable.
   func toggleReminderForItemAtIndexPath(indexPath: NSIndexPath) -> (newSetting: Bool, success: Bool, reason: String) {
      
      var success = false
      var newSetting = false
      var message = "Unknown Error."
      
      // Retreive timetable item
      let timetableItem = self.itemAtIndexPath(indexPath)
      
      // Retrieve current setting
      let currentSetting = reminderModel.timetableReminderIsSet(forTimetableItem: timetableItem)
      newSetting = !currentSetting.setting
      
      // Set new setting
      let setResult = reminderModel.setTimetableReminder(forTimetableItem: timetableItem, enabled: newSetting)
      success = setResult.success
      message = setResult.message
      
      // Return new setting.
      return (newSetting, success, message)
   }
   
   // Returns a tuple containing the reminder status at a specifc index path and an error message of necessary.
   func reminderSettingForItemAtIndexPath(indexPath: NSIndexPath) -> (setting: Bool, message: String) {
      
      // Retreive timetable item
      let timetableItem = self.itemAtIndexPath(indexPath)
      
      // Return reminder setting from reminder model.
      return reminderModel.timetableReminderIsSet(forTimetableItem: timetableItem)
   }
   
   // Retrieves stopping pattern from the API.
   func getStoppingPattern() {
      
      // Clear existing pattern
      self.stoppingPattern = []
      
      // Create and perform health check
      var healthCheck = PTVHealthCheck()
      healthCheck.performHealthCheck { (healthCheckResult) in
         // Confirm health check returned positive result. Send failure to delegate if not.
         if healthCheckResult == .Fail || healthCheckResult == .Unknown {
            
            self.delegate?.stoppingPatternUpdateFailed()
            return
            
         }
         
         // Generate query URL
         let queryType = PTVURLQueryType.StoppingPattern
         let modeParam = PTVURLParameter("mode", value: String(self.line.routeType.rawValue))
         let runParam = PTVURLParameter("run", value: String(self.run.runID))
         let stopParam = PTVURLParameter("stop", value: String(self.stop.stopID))
         let timeParam = PTVURLOptionalParameter("for_utc", value: PTVUTCTime.currentUTCTime)
         
         guard let queryURL = PTVURLGenerator.generateUsing(queryType: queryType, parameters: [modeParam, runParam, stopParam, timeParam]) else {
            self.delegate?.stoppingPatternUpdateFailed()
            return
         }
         
         // Perform request with Alamofire
         Alamofire.request(.GET, queryURL.absoluteString).responseJSON(completionHandler: { (responseData) in
            
            // Process response
            if let responseValue = responseData.result.value {
               let swiftyJSON = JSON(responseValue)
               
               for item in swiftyJSON["values"].arrayValue {
                  
                  let timetableItem = PTVTimetableItem(item.dictionaryValue)
                  self.stoppingPattern.append(timetableItem)
               }
               
               self.delegate?.stoppingPatternDidUpdate()
               
            } else {
               self.delegate?.stoppingPatternUpdateFailed()
            }
         })
         
      }
   }
}