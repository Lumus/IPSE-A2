//
//  PTVPlatform.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import SwiftyJSON

class PTVPlatform: NSObject, NSCoding {
   
   // Constants
   private let kPTVPlatformRealtimeIDKey = "realtime_id"
   private let kPTVPlatformStopKey = "stop"
   private let kPTVPlatformDirectionKey = "direction"
   
   // Variables
   private(set) var realtimeID = 0
   private(set) var platformStop: PTVStop?
   private(set) var platformDirection: PTVDirection?
   override var description: String {
      get {
         return "{ ID: \(realtimeID), Stop: \(platformStop), Platform: \(platformDirection) }"
      }
   }
   
   init(_ data: [String: JSON])
   {
      if let timeID = data[kPTVPlatformRealtimeIDKey]?.int {
         self.realtimeID = timeID
      }
      
      if let stop = data[kPTVPlatformStopKey]?.dictionary {
         self.platformStop = PTVStop(stop)
      }
      
      if let direction = data[kPTVPlatformDirectionKey]?.dictionary {
         self.platformDirection = PTVDirection(direction)
      }
   }
   
   init(id realtimeID: Int, stop: PTVStop?, direction: PTVDirection?) {
      self.realtimeID = realtimeID
      self.platformStop = stop
      self.platformDirection = direction
   }
   
   // MARK: - NSCoding
   
   required init?(coder aDecoder: NSCoder) {
      let realtimeID = aDecoder.decodeIntegerForKey(self.kPTVPlatformRealtimeIDKey)
      self.realtimeID = realtimeID
      
      if let stop = aDecoder.decodeObjectForKey(self.kPTVPlatformStopKey) as? PTVStop {
         self.platformStop = stop
      }
      
      if let direction = aDecoder.decodeObjectForKey(self.kPTVPlatformDirectionKey) as? PTVDirection {
         self.platformDirection = direction
      }
   }
   
   func encodeWithCoder(coder: NSCoder) {
      
      coder.encodeInteger(self.realtimeID, forKey: self.kPTVPlatformRealtimeIDKey)
      coder.encodeObject(self.platformStop, forKey: self.kPTVPlatformStopKey)
      coder.encodeObject(self.platformDirection, forKey: self.kPTVPlatformDirectionKey)
      
   }
}
