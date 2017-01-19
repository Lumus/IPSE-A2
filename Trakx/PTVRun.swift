//
//  PTVRun.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import SwiftyJSON

class PTVRun: NSObject, NSCoding {
   
   // Constants
   private let kPTVRunTransportTypeKey = "transport_type" //: PTVLineType
   private let kPTVRunIDKey = "run_id" //: Int
   private let kPTVRunNumSkippedKey = "num_skipped" //: Int
   private let kPTVRunDestinationIDKey = "destination_id" //: Int
   private let kPTVRunDestinationNameKey = "destination_name" //: String
   
   // Variables
   private(set) var transportType = PTVLineType.MetroTrain
   private(set) var runID = 0
   private(set) var numSkipped = 0
   private(set) var destinationID = 0
   private(set) var destinationName = ""
   
   override var description: String {
      get {
         return "{ Type: \(transportType), ID: \(runID), Skipped: \(numSkipped), DestID: \(destinationID), DestName: \(destinationName) }"
      }
   }
   
   init(_ data: [String: JSON])
   {
      if let transport = data[kPTVRunTransportTypeKey]?.string {
         let type = PTVLineType(stringValue: transport)
         self.transportType = type!
      }
      
      if let rID = data[kPTVRunIDKey]?.int {
         self.runID = rID
      }
      
      if let skipped = data[kPTVRunNumSkippedKey]?.int {
         self.numSkipped = skipped
      }
      
      if let destID = data[kPTVRunDestinationIDKey]?.int {
         self.destinationID = destID
      }
      
      if let destName = data[kPTVRunDestinationNameKey]?.string {
         self.destinationName = destName
      }
   }
   
   init(type transportType: PTVLineType, runID: Int, numSkipped: Int, destinationID: Int, destinationName: String) {
      self.transportType = transportType
      self.runID = runID
      self.numSkipped = numSkipped
      self.destinationID = destinationID
      self.destinationName = destinationName 
   }
   
   // MARK: - NSCoding protocol
   required init?(coder aDecoder: NSCoder) {
      let transportRawValue = aDecoder.decodeIntegerForKey(self.kPTVRunTransportTypeKey)
      if let transportType = PTVLineType(rawValue: transportRawValue) {
         self.transportType = transportType
      }
      
      let runID = aDecoder.decodeIntegerForKey(self.kPTVRunIDKey)
      self.runID = runID
      
      let skipped = aDecoder.decodeIntegerForKey(self.kPTVRunNumSkippedKey)
      self.numSkipped = skipped
      
      let destID = aDecoder.decodeIntegerForKey(self.kPTVRunDestinationIDKey)
      self.destinationID = destID
      
      if let destName = aDecoder.decodeObjectForKey(self.kPTVRunDestinationNameKey) as? String {
         self.destinationName = destName
      }
   }
   
   func encodeWithCoder(coder: NSCoder) {
      coder.encodeInteger(self.transportType.rawValue, forKey: self.kPTVRunTransportTypeKey)
      coder.encodeInteger(self.runID, forKey: self.kPTVRunIDKey)
      coder.encodeInteger(self.numSkipped, forKey: self.kPTVRunNumSkippedKey)
      coder.encodeInteger(self.destinationID, forKey: self.kPTVRunDestinationIDKey)
      coder.encodeObject(self.destinationName, forKey: self.kPTVRunDestinationNameKey)
   }
   
}
