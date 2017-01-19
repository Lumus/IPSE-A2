//
//  PTVStop.swift
//  Trakx
//
//  Created by Matt Croxson on 28/06/2015.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON


class PTVStop: PTVLocation {
   
   // Constants
   private static let kPTVStopSuburbKey = "suburb"
   private static let kPTVStopTransportTypeKey = "transport_type"
   private static let kPTVStopIDKey = "stop_id"
   
   // Stored Properties
   private(set) var suburb = ""
   private(set) var transportType = PTVLineType.MetroTrain
   private(set) var stopID = 0
   
   // Overrides
   
   override var description: String {
      get {
         return "{ Suburb: \(suburb), Type: \(transportType), StopID: \(stopID) }"
      }
   }
   
   override init(_ data: [String: JSON]) {

      // Initialise superclass
      super.init(data)
      
      // Initialise self
      if let sub = data[PTVStop.kPTVStopSuburbKey]?.string {
         self.suburb = sub
      }
      
      if let transport = data[PTVStop.kPTVStopTransportTypeKey]?.string {
         let type = PTVLineType(stringValue: transport)
         self.transportType = type!
      }
      
      if let stop = data[PTVStop.kPTVStopIDKey]?.int {
         self.stopID = stop
      }

   }
   
   init(suburb: String, transportType: PTVLineType, stopID: Int, locationName: String, latitude: Double, longitude: Double, distance: Double)
   {
      
      // Initialise superclass
      super.init(lat: latitude, lon: longitude, locationName: locationName, distance: distance)
      
      // Initialise self
      self.suburb = suburb
      self.transportType = transportType
      self.stopID = stopID

   }
   
   // MARK: - MKAnnotation Protocol
   var subtitle: String? {
      get {
         return "\(self.suburb) - \(self.transportType)"
      }
   }
   
   // MARK: - NSCoder Protocol
   required init?(coder decoder: NSCoder) {
      
      // Decode superclass
      super.init(coder: decoder)
      
      // Decode self
      guard let sub = decoder.decodeObjectForKey(PTVStop.kPTVStopSuburbKey) as? String,
         let trans = decoder.decodeObjectForKey(PTVStop.kPTVStopTransportTypeKey) as? String else { return nil }
      
      let stop_id = Int(decoder.decodeIntForKey(PTVStop.kPTVStopIDKey))
      
      guard let type = PTVLineType(stringValue: trans) else { return nil }
      
      self.suburb = sub
      self.transportType = type
      self.stopID = stop_id
      
   }
   
   override func encodeWithCoder(aCoder: NSCoder) {
      
      // Encode superclass
      super.encodeWithCoder(aCoder)
      
      // Encode self
      aCoder.encodeObject(self.suburb, forKey: PTVStop.kPTVStopSuburbKey)
      aCoder.encodeObject(self.transportType.stringValue, forKey:  PTVStop.kPTVStopTransportTypeKey)
      aCoder.encodeInt(Int32(self.stopID), forKey: PTVStop.kPTVStopIDKey)

   }
}
