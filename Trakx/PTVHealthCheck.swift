//
//  PTVHealthCheck.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

struct PTVHealthCheck {
   
   // MARK: - Constants
   private let kPTVHealthCheckSecurityTokenOKKey = "securityTokenOK"
   private let kPTVHealthCheckClientClockOKKey = "clientClockOK"
   private let kPTVHealthCheckMemCacheOKKey = "memcacheOK"
   private let kPTVHealthCheckDatabaseOKKey = "databaseOK"
   
   // MARK: - Variables
   
   // Stores the result of the last health check performed.
   private var lastHealthCheckResult: PTVHealthCheckResult = .Unknown
   
   // Name of query for URL builder.
   private let queryName = PTVURLQueryType.HealthCheck
   
   /// Executes health check and performs completion handler once retreived.
   mutating func performHealthCheck(completion completionHandler: (healthCheckResult: PTVHealthCheckResult ) -> Void ) {
      
      // Generate parameters
      let timestamp = PTVURLOptionalParameter("timestamp", value: PTVUTCTime.currentUTCTime)
      
      // Generate query
      let query = PTVQuery(queryName, parameters: timestamp)
      
      // Generate query URL
      guard let queryURL = PTVURLGenerator.generateUsing(query: query) else {
         self.lastHealthCheckResult = .Unknown
         
         completionHandler(healthCheckResult: self.lastHealthCheckResult)
         
         return
      }
      
      // Perform request and process response.
      Alamofire.request(.GET, queryURL.absoluteString).responseJSON { (responseJSON) in
         if let responseData = responseJSON.result.value {
            let swiftyJSON = JSON(responseData)
            
            // Extract response items from JSON data.
            var securityTokenOK = false
            var clientClockOK = false
            var memCacheOK = false
            var databaseOK = false
            
            if let token = swiftyJSON[self.kPTVHealthCheckSecurityTokenOKKey].bool {
               securityTokenOK = token
            }
            
            if let clock = swiftyJSON[self.kPTVHealthCheckClientClockOKKey].bool
            {
               clientClockOK = clock
            }
            
            if let cache = swiftyJSON[self.kPTVHealthCheckMemCacheOKKey].bool {
               memCacheOK = cache
            }
            
            if let dbase = swiftyJSON[self.kPTVHealthCheckDatabaseOKKey].bool {
               databaseOK = dbase
            }
            
            // Set return object based on flag response
            if databaseOK == false || securityTokenOK == false { self.lastHealthCheckResult = .Fail; }
            else if memCacheOK == false || clientClockOK == false { self.lastHealthCheckResult = .Unhealthy; }
            else { self.lastHealthCheckResult = .Healthy; }
            
            completionHandler(healthCheckResult: self.lastHealthCheckResult)
         }
      }
   }
}
