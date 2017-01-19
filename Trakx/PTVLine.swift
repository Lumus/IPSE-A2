//
//  PTVLine.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 A PTVLine object represents a line for a specified transport mode.
 
 - See: [PTVLineType](../Enums/PTVLineType.html)
 */
class PTVLine: NSObject, NSCoding {
   
   // *********************************
   // MARK: - Constants (Keys)
   // *********************************
   private let kPTVLineTransportTypeKey = "transport_type"
   private let kPTVLineRouteTypeKey = "route_type"
   private let kPTVLineIDKey = "line_id"
   private let kPTVLineNameKey = "line_name"
   private let kPTVLineNumberKey = "line_number"
   private let kPTVLineNameShortKey = "line_name_short"
   private let kPTVLineNumberLongKey = "line_number_long"
   
   // *********************************
   // MARK: - Variables
   // *********************************
   /**
    Transport type for the line.
    
    - See: [PTVLineType](../Enums/PTVLineType.html)
    */
   //   @available(*, deprecated=2.1.1)
   private(set) var transportType = PTVLineType.MetroTrain
   
   /**
    Transport type for the line.
    
    - See: [PTVLineType](../Enums/PTVLineType.html)
    */
   private(set) var routeType = PTVLineType.MetroTrain
   
   /// Unique identifier for the line.
   private(set) var lineID = 0
   /// The name of the line (e.g. "Sunbury Line", "970 - City - Frankston - Mornington - Rosebud via Nepean Highway & Frankston Station"
   private(set) var lineName = ""
   /// The number of the line. For train lines, this is the same as the line name.
   private(set) var lineNumber = ""
   /// A shortened version of line name, removing the line number prefix (where applicable)
   private(set) var lineNameShort = ""
   /// An extended version of the line number.
   private(set) var lineNumberLong = ""
   
   // *********************************
   // MARK: - Initialiser
   // *********************************
   
   /**
    Initialises and returns an instance using data provided by the API.
    
    - Parameter data: A Dictionary object containing the raw data from the API.
    - Returns: An initialised PTVDisruption object.
    */
   init(_ data: [String: JSON]) {
      
      if let transport = data[kPTVLineTransportTypeKey]?.string {
         if let type = PTVLineType(stringValue: transport) {
            self.transportType = type
         }
      }
      
      if let line = data[kPTVLineIDKey]?.int {
         self.lineID = line
      }
      
      if let name = data[kPTVLineNameKey]?.string {
         self.lineName = name
      }
      
      if let number = data[kPTVLineNumberKey]?.string {
         self.lineNumber = number
      }
      
      if let nameShort = data[kPTVLineNameShortKey]?.string{
         self.lineNameShort = nameShort
      }
      
      if let numberLong = data[kPTVLineNumberLongKey]?.string {
         self.lineNumberLong = numberLong
      }
      
      if let route = data[kPTVLineRouteTypeKey]?.int {
         if let type = PTVLineType(rawValue: route) {
            self.routeType = type
         }
      }
   }
   
   init(transportType: PTVLineType,
        routeType: PTVLineType,
        lineID: Int,
        lineName: String,
        lineNumber: String,
        lineNameShort: String,
        lineNumberLong: String) {
   }
   
   // MARK: - NSCoding protocol
   required init?(coder aDecoder: NSCoder) {
      let routeInt = aDecoder.decodeIntegerForKey(self.kPTVLineRouteTypeKey)
      if let route = PTVLineType(rawValue: routeInt) {
         self.routeType = route
      }
      
      let lineID = aDecoder.decodeIntegerForKey(self.kPTVLineIDKey)
      self.lineID = lineID
      
      if let lineName = aDecoder.decodeObjectForKey(self.kPTVLineNameKey) as? String {
         self.lineName = lineName
      }
      
      if let lineNumber = aDecoder.decodeObjectForKey(self.kPTVLineNumberKey) as? String {
         self.lineNumber = lineNumber
      }
      
      if let lineNameShort = aDecoder.decodeObjectForKey(self.kPTVLineNameShortKey) as? String {
         self.lineNameShort = lineNameShort
      }
      
      if let lineNumberLong = aDecoder.decodeObjectForKey(self.kPTVLineNumberLongKey) as? String {
         self.lineNumberLong = lineNumberLong
      }
   }
   
   func encodeWithCoder(coder: NSCoder) {
      coder.encodeInteger(self.routeType.rawValue, forKey: self.kPTVLineRouteTypeKey)
      coder.encodeInteger(self.lineID, forKey: self.kPTVLineIDKey)
      coder.encodeObject(self.lineName, forKey: self.kPTVLineNameKey)
      coder.encodeObject(self.lineNumber, forKey: self.kPTVLineNumberKey)
      coder.encodeObject(self.lineNameShort, forKey: self.kPTVLineNameShortKey)
      coder.encodeObject(self.lineNumberLong, forKey: self.kPTVLineNumberLongKey)
   }
}
