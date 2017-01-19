//
//  NextDeparturesModel.swift
//  Trakx
//
//  Created by Matt Croxson on 14/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Alamofire
import SwiftyJSON

protocol NextDeparturesModelDelegate {
   func timetableWillUpdate()
   func timetableDidUpdate()
   func timetableUpdateFailed()
}

class NextDeparturesModel {
   
   var timetable = [PTVDirection: [PTVTimetableItem]]()
   var timetableKeys = [PTVDirection]()
   var delegate: NextDeparturesModelDelegate?
   var stop: PTVStop
   
   init(stop: PTVStop, delegate: NextDeparturesModelDelegate? = nil) {
      self.stop = stop
      self.delegate = delegate
      self.getBroadNextDepartures()
   }
   
   var nextDeparture: PTVTimetableItem? {
      get {
         var items = Array(self.timetable.values.flatten())
         
         items.sortInPlace({ return $0.timetableTimeUTC == $1.timetableTimeUTC.earlierDate($0.timetableTimeUTC) })
         
         if items.count > 0 {
            return items[1]
         }
         
         return nil
      }
   }
   
   func getBroadNextDepartures() {
      // Clear existing timetable
      self.timetable = [:]
      
      // Create and perform health check with completion handler
      var healthCheck = PTVHealthCheck()
      healthCheck.performHealthCheck { (healthCheckResult) in
         
         // Confirm health check returned positive result. Send failure to delegate if not.
         if healthCheckResult == .Fail || healthCheckResult == .Unknown {
            dispatch_async(dispatch_get_main_queue(), {
               self.delegate?.timetableUpdateFailed()
            })
            return
            
         }
         
         // Generate query URL
         let queryType = PTVURLQueryType.BroadNextDepartures
         let stopParam = PTVURLParameter("stop", value: String(self.stop.stopID))
         let modeParam = PTVURLParameter("mode", value: String(self.stop.transportType.rawValue))
         let limitParam = PTVURLParameter("limit", value: String(5))
         
         guard let queryURL = PTVURLGenerator.generateUsing(queryType: queryType, parameters: [modeParam, stopParam, limitParam]) else {
            dispatch_async(dispatch_get_main_queue(), {
               self.delegate?.timetableUpdateFailed()
            })
            
            return
         }
         
         // Perform request with Alamofire
         Alamofire.request(.GET, queryURL.absoluteString).responseJSON(completionHandler: { (responseData) in
            
            // Process response
            if let responseValue = responseData.result.value {
               let swiftyJSON = JSON(responseValue)
               
               for item in swiftyJSON["values"].arrayValue {
                  let timetableItem = PTVTimetableItem(item.dictionaryValue)
                  if let direction = timetableItem.timetablePlatform?.platformDirection {
                     
                     if self.timetable[direction] == nil {
                        self.timetable[direction] = [PTVTimetableItem]()
                     }
                     
                     self.timetable[direction]?.append(timetableItem)
                     
                  }
               }
               
               self.timetableKeys = Array(self.timetable.keys)
               self.sortTimetableKeys()
               
               dispatch_async(dispatch_get_main_queue(), {
                  self.delegate?.timetableDidUpdate()
               })
               
               
            } else {
               dispatch_async(dispatch_get_main_queue(), {
                  self.delegate?.timetableUpdateFailed()
               })
            }
         })
      }
   }
   
   private func sortTimetableKeys() {
      self.timetableKeys.sortInPlace({ $0.directionName < $1.directionName })
   }
}