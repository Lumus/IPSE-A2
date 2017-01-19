//
//  LineDetailModel.swift
//  Trakx
//
//  Created by Matt Croxson on 3/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol LineDetailModelDelegate {
   func lineDetailWillUpdate()
   func lineDetailDidUpdate()
   func lineDetailUpdateFailed(message: String)
}

class LineDetailModel {
   private let line: PTVLine!
   private var stoppingPattern: [PTVStop] = []
   private let reminderModel = ReminderModel.sharedModel
   
   private let delegate: LineDetailModelDelegate?
   
   init(line: PTVLine, delegate: LineDetailModelDelegate? = nil) {
      self.line = line
      self.delegate = delegate
   }
   
   var numberOfSections: Int {
      get {
         return 1
      }
   }
   
   func numberOfStopsInSection(section: Int) -> Int {
      return self.stoppingPattern.count
   }
   
   func stopAtIndexPath(indexPath: NSIndexPath) -> PTVStop {
      return self.stoppingPattern[indexPath.row]
   }
   
   func toggleReminderForItemAtIndexPath(indexPath: NSIndexPath) -> (newSetting: Bool, success: Bool, reason: String) {
      
      var success = false
      var newSetting = false
      var message = "Unknown Error."
      
      // Retreive timetable item
      let stopItem = self.stopAtIndexPath(indexPath)
      
      // Retrieve current setting
      let currentSetting = reminderModel.locationReminderIsSet(forStop: stopItem)
      newSetting = !currentSetting.setting
      
      // Set new setting
      let setResult = reminderModel.setLocationReminder(forStop: stopItem, enabled: newSetting)
      success = setResult.success
      message = setResult.message
      
      // Return new setting.
      return (newSetting, success, message)
   }
   
   func reminderSettingForStopAtIndexPath(indexPath: NSIndexPath) -> (setting: Bool, message: String) {
      
      // Retrieve stop item
      let stopItem = self.stopAtIndexPath(indexPath)
      
      // Return reminder setting from reminder model.
      return reminderModel.locationReminderIsSet(forStop: stopItem)
   }
   
   func setReminderForStopWithSetting(setting: Bool, atIndexPath indexPath: NSIndexPath) -> (success: Bool, message: String) {
      
      // Retrieve stop item
      let stopItem = self.stopAtIndexPath(indexPath)
      
      // Set location reminder and return result
      let result = reminderModel.setLocationReminder(forStop: stopItem, enabled: setting)
      
      return result
      
   }
   
   func getStopsOnLine() {
      
      // Tell delegate retrieve is about to occur
      self.delegate?.lineDetailWillUpdate()
      
      // Clear existing stops
      self.stoppingPattern = []
      
      // Create and perform health check
      var healthCheck = PTVHealthCheck()
      healthCheck.performHealthCheck { (healthCheckResult) in
         // Confirm health check returned positive result. Send failure to delegate if not.
         if healthCheckResult == .Fail || healthCheckResult == .Unknown {
            
            self.delegate?.lineDetailUpdateFailed("Service not available")
            return
            
         }
         
         // Generate query URL
         let queryType = PTVURLQueryType.StopsOnALine
         let queryModeParam = PTVURLParameter("mode", value: String(self.line.routeType.rawValue))
         let queryLineParam = PTVURLParameter("line", value: String(self.line.lineID))
         
         guard let queryURL = PTVURLGenerator.generateUsing(queryType: queryType, parameters: [queryModeParam, queryLineParam]) else {
            self.delegate?.lineDetailUpdateFailed("An error has occured sending the request. Please try again later.")
            return
         }
         
         // Perform request with Alamofire
         Alamofire.request(.GET, queryURL.absoluteString).responseJSON(completionHandler: { (responseData) in
            
            // Process response
            if let responseValue = responseData.result.value {
               let swiftyJSON = JSON(responseValue)
               
               for item in swiftyJSON.arrayValue {
                  
                  let stopItem = PTVStop(item.dictionaryValue)
                  self.stoppingPattern.append(stopItem)
               }
               
               self.delegate?.lineDetailDidUpdate()
               
            } else {
               self.delegate?.lineDetailUpdateFailed("An error occured processing the server response. Please try again later.")
            }
         })
         
      }
   }
}