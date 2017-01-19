//
//  PTVResult.swift
//  Trakx
//
//  Created by Matt Croxson on 03/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import SwiftyJSON

enum PTVSearchResultType: String, CustomStringConvertible, Equatable {
   case Stop = "stop"
   case Line = "line"
   
   // Returns a human-readable textual description of the disruption status.
   var description: String {
      get {
         switch self {
         case .Stop: return "Stop"
         case .Line: return "Line"
         }
      }
   }
   
   // Returns an array of all search result types.
   static var allTypes: [PTVSearchResultType] {
      get {
         return [.Stop, .Line]
      }
   }
}

struct PTVSearchResult {
   
   // Variables
   private(set) var stopObject: PTVStop?
   private(set) var lineObject: PTVLine?
   private(set) var searchResultType: PTVSearchResultType = .Stop
   
   var description: String {
      get {
         switch self.searchResultType {
         case .Stop:
            return self.stopObject!.description
            
         case .Line:
            return self.lineObject!.description
         }
      }
   }
   
   var title: String {
      get {
         switch self.searchResultType {
         case .Stop:
            return self.stopObject!.title!
            
         case .Line:
            return self.lineObject!.lineNameShort
         }
      }
   }
   
   var subtitle: String {
      get {
         switch self.searchResultType {
         case .Stop:
            return self.stopObject!.subtitle!
            
         case .Line:
            return self.lineObject!.routeType.description
            
         }
      }
   }
   
   // Initialiser
   init?(_ data: [String: JSON]) {
      // Extract object from result dictionary and continue if valid.
      if let object = data["result"]?.dictionary {
         
         // Extract result type from result dictionary and continue if valid
         if let typeString = data["type"]?.string {
            if let resultType = PTVSearchResultType(rawValue: typeString) {
               self.searchResultType = resultType
               
               // Check result type and initliase the correct object.
               if resultType == .Stop {
                  self.stopObject = PTVStop(object)
               } else {
                  self.lineObject = PTVLine(object)
               }
            }
         }
      }
   }
}
