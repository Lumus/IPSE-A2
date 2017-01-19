//
//  DisruptionsModel.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DisruptionsModel: NSObject {
   
   // Singleton Instance  
   static let sharedModel = DisruptionsModel()
   
   // Notification Keys
   static let disruptionModelWillUpdateNotificationID = "DisruptionsModelWillUpdate"
   static let disruptionModelDidUpdateNotificationID = "DisruptionsModelDidUpdate"
   static let disruptionModelFailedUpdateNotificationID = "DisruptionsModelFailedUpdate"
   
   // Stores updating status.
   var disruptionsUpdating: Bool = true
   
   // Stores disruptions returned by the API
   var disruptions = [PTVDisruptionMode: [PTVDisruption]]()
   
   // Returns the number of disruptions in the specified section
   func disruptionCountForSection(section: Int) -> Int {
      
      let mode = Array(self.disruptions.keys)[section]
      return self.disruptionCountForModes([mode])
      
   }
   
   // Returns a disruption for a specific mode at a specified row, or nil if not found.
   func disruptionForMode(mode: PTVDisruptionMode, atRow row: Int) -> PTVDisruption? {
      return self.disruptions[mode]?[row]
   }
   
   // Returns a disruption at a specific index path, or nil if not found.
   func disruptionModeForIndexPath(indexPath: NSIndexPath) -> PTVDisruptionMode? {
      return Array(self.disruptions.keys)[indexPath.row]
   }
   
   // Returns a disruption mode at a specific index path.
   func availableDisruptionModeForIndexPath(indexPath: NSIndexPath) -> PTVDisruptionMode? {
      return self.availableDisruptionModes[indexPath.row]
   }
   
   // Returns the total cound of disruptions for the specified modes.
   func disruptionCountForModes(disruptionModes: [PTVDisruptionMode]) -> Int {
      
      // Store result
      var count = 0
      
      // Iterate over disruptions and add to count where mode matches one of the modes passed.
      for (mode, disruptionArray) in self.disruptions where disruptionModes.contains(mode) {
         count = count + disruptionArray.count
      }
      
      // Return result.
      return count
   }
   
   // Get the status mode at a specific index path.
   func disruptionStatusForModeAtIndexPath(indexPath: NSIndexPath) -> PTVDisruptionStatus {
      let disruptionStatus: PTVDisruptionStatus = self.disruptionCountForSection(indexPath.row) > 0 ? .Several : .None
      
      return disruptionStatus
   }
   
   // Return a count of disruption modes.
   var disruptionModeCount: Int {
      get {
         return self.disruptions.keys.count
      }
   }
   
   // Returns the total count of disruptions.
   var disruptionCount: Int {
      get {
         let modes = Array(self.disruptions.keys)
         return self.disruptionCountForModes(modes)
      }
   }
   
   // Helper function to post a notification for any listening objects.
   private func postNotification(notificationType: PTVDisruptionNotificationType) {
      
      switch notificationType {
      case .WillUpdate: // Advises that the disruptions are about to update.
         self.disruptionsUpdating = true
         NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: DisruptionsModel.disruptionModelWillUpdateNotificationID, object: nil))
         
      case .DidUpdate: // Advises that the disruptions did update.
         self.disruptionsUpdating = false
         NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: DisruptionsModel.disruptionModelDidUpdateNotificationID, object: nil))
         
      case .FailedUpdate: // Advises that the disruption update failed.
         self.disruptionsUpdating = false
         NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: DisruptionsModel.disruptionModelFailedUpdateNotificationID, object: nil))
         
      }
   }
   
   // Retrieve disruptions from the API.
   func getDisruptions() {
      // Clear existing disruptions
      var defaultDisruptions = [PTVDisruptionMode: [PTVDisruption]]()
      
      for mode in PTVDisruptionMode.allOptions {
         defaultDisruptions[mode] = [PTVDisruption]()
      }
      
      self.disruptions = defaultDisruptions
      
      // Post will update notification
      self.postNotification(.WillUpdate)
      
      // Create and peform health check with completion handler
      var healthCheck = PTVHealthCheck()
      healthCheck.performHealthCheck { (healthCheckResult) in
         
         // Confirm health check returned positive result. Post failure notification if not.
         if healthCheckResult == .Fail || healthCheckResult == .Unknown {
            
            self.postNotification(.FailedUpdate)
            return
            
         }
         
         // Generate query URL
         let queryType: PTVURLQueryType = .Disruptions
         let queryParameter = PTVURLParameter("modes", value: PTVDisruptionMode.allOptionsCSV)
         guard let queryURL = PTVURLGenerator.generateUsing(queryType: queryType, parameter: queryParameter) else {
            
            self.postNotification(.FailedUpdate)
            return
            
         }
         
         // Perform request with Alamofire
         Alamofire.request(.GET, queryURL.absoluteString).responseJSON {
            (responseData) -> Void in
            
            // Process response.
            if let responseValue = responseData.result.value {
               let swiftyJSON = JSON(responseValue)
               
               for (mode, disruptionList) in swiftyJSON.dictionaryValue {
                  guard let mode = PTVDisruptionMode(rawValue: mode) else { break }
                  
                  for disruption in disruptionList.arrayValue {
                     let newDisruption = PTVDisruption(disruption.dictionaryValue)
                     self.disruptions[mode]?.append(newDisruption)
                  }
               }
               
               // Post success notification on main thread.
               
               self.postNotification(.DidUpdate)
               
               return
               
            } else {
               self.postNotification(.FailedUpdate)
               
               return
            }
         }
      }
   }
   
   // Returns an array of all disruptions modes. 
   var availableDisruptionModes: [PTVDisruptionMode] {
      get {
         return PTVDisruptionMode.allOptions
      }
   }
}

// Used with post notification helper function.
private enum PTVDisruptionNotificationType {
   case WillUpdate, DidUpdate, FailedUpdate
}