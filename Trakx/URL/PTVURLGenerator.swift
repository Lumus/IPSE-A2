//
//  PTVURLGenerator.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2015 Matt Croxson. All rights reserved.
//

import UIKit

enum PTVURLQueryType: String {
   case HealthCheck = "healthcheck"
   case Disruptions = "disruptions"
   case StopsNearby = "nearme"
   case POIByMap = "poibymap"
   case Search = "search"
   case LinesByMode = "lines"
   case StopsOnALine = "stops-for-line"
   case BroadNextDepartures = "departures/by-destination"
   case SpecificNextDepartures = "departures/all"
   case StoppingPattern = "stopping-pattern"
}

class PTVURLGenerator {
   
   static func generateUsing(query query: PTVQuery) -> NSURL? {
      return self.generateUsing(queryType: query.queryType, parameters: query.parameters)
   }
   
   static func generateUsing(queryType queryType: PTVURLQueryType, parameter: PTVURLParameter) -> NSURL? {
      return self.generateUsing(queryType: queryType, parameters: [parameter])
   }
   
   /// Generates an NSURL object to send to the PTV API
   /// - Parameter query: The query being performed.
   static func generateUsing(queryType queryType: PTVURLQueryType, parameters: [PTVURLParameter]) -> NSURL? {
      
      // Array to hold optional parameters
      var optionals = Array<PTVURLOptionalParameter>()
      var postParameters = Array<PTVURLParameter>()
      
      // Base URL
      var requestURL = PTVCommonData.baseURLWithVersion
      
      if queryType == .StopsNearby || queryType == .Disruptions || queryType == .LinesByMode {
         requestURL.appendContentsOf(queryType.rawValue + "/")
      }
      
      // Append each required parameter to base URL
      for parameter in parameters {
         if parameter is PTVURLOptionalParameter {
            // Store optional parameters for later
            if parameter.complete != "" {
               optionals.append(parameter as! PTVURLOptionalParameter)
            }
         }
         else {
            if parameter.name == "limit" && queryType != .POIByMap
            {
               postParameters.append(parameter)
            } else {
            requestURL.appendContentsOf(parameter.complete)
            requestURL.appendContentsOf("/")
            }
         }
      }
      
      // Append query to Base URL
      if queryType.rawValue == "" || queryType == .POIByMap || queryType == .StopsNearby || queryType == .Disruptions || queryType == .Search || queryType == .LinesByMode {
         // Remove last "/" from URL
         requestURL.removeAtIndex(requestURL.endIndex.predecessor())
      }
      else
      {
         requestURL.appendContentsOf(queryType.rawValue)
      }
      if postParameters.count != 0 {
         requestURL.appendContentsOf("/")
         for parameter in postParameters
         {
            requestURL.appendContentsOf(parameter.complete)
         }
      }
      
      // Append any options to Base URL
      if optionals.count != 0 {
         requestURL.appendContentsOf("?")
         for parameter in optionals
         {
            requestURL.appendContentsOf(parameter.complete)
         }
      }
      
      
      // Retreived signed URL
      let signedURL = HMACBridge.signedURLWithPath(requestURL)
      
      // Return NSURL of String provided.
      return signedURL
      
   }
}
